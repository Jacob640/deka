{-# LANGUAGE OverloadedStrings #-}
module Runner where

import qualified Parse as P
import qualified Data.ByteString.Char8 as BS8
import Data.Monoid
import Data.List (intersperse)
import System.Exit
import Data.Foldable (toList)
import qualified Data.Sequence as S
import Data.Sequence ((|>))
import Pipes
import Pipes.Prelude (fold)
import qualified Control.Monad.Trans.State as St
import NumTests (testLookups)
import Types

produceFile
  :: MonadIO m
  => BS8.ByteString
  -> Producer P.File m ()
produceFile fn = liftIO (P.parseFile fn) >>= yield

contents
  :: Monad m
  => P.File
  -> Producer (Either P.File P.Instruction) m ()
contents f = each (P.fileContents f)

eiToInstructions
  :: Monad m
  => Either P.File P.Instruction
  -> Producer P.Instruction m ()
eiToInstructions ei = case ei of
  Right i -> yield i
  Left f -> for (contents f) eiToInstructions

instructions
  :: MonadIO m
  => BS8.ByteString
  -> Producer P.Instruction m ()
instructions bs = for (produceFile bs) (eiToInstructions . Left)

type State = St.StateT (S.Seq (P.Keyword, P.Value))

procInstruction
  :: Monad m
  => Pipe P.Instruction P.TestSpec (State m) ()
procInstruction = do
  ins <- await
  case ins of
    P.Blank -> procInstruction
    P.Directive k v -> do
      lift (St.modify (|> (k,v)))
      procInstruction
    P.Test ts -> yield ts

data TestOutput = TestOutput
  { outSpec :: P.TestSpec
  , outResult :: Maybe Bool
  , outLog :: S.Seq BS8.ByteString
  }

procSpec :: Monad m => Pipe P.TestSpec TestOutput (State m) ()
procSpec = do
  spc <- await
  case lookup (P.testOperation spc) testLookups of
    Nothing -> yield (noOperation spc)
    Just f -> do
      dirs <- lift St.get
      yield (runTest dirs spc f)

noOperation :: P.TestSpec -> TestOutput
noOperation ts = TestOutput
  { outSpec = ts
  , outResult = Nothing
  , outLog = S.singleton "no matching operation; skipping"
  }

runTest
  :: S.Seq (P.Keyword, P.Value)
  -> P.TestSpec
  -> Test
  -> TestOutput
runTest ds ts t = TestOutput
  { outSpec = ts
  , outResult = r
  , outLog = l
  }
  where
    (r, l) = t ds (P.testOperands ts) (P.testResult ts)
      (P.testConditions ts)

printTest
  :: MonadIO m
  => Pipe TestOutput (Maybe Bool) m ()
printTest = do
  o <- await
  liftIO . BS8.putStr . showResult $ o
  yield (outResult o)

tally :: Counts -> Maybe Bool -> Counts
tally (Counts p f s) mb = case mb of
  Nothing -> Counts p f (s + 1)
  Just True -> Counts (p + 1) f s
  Just False -> Counts p (f + 1) s

totals :: Monad m => Producer (Maybe Bool) m () -> m Counts
totals = fold tally (Counts 0 0 0) id

produceResults
  :: MonadIO m
  => [BS8.ByteString]
  -- ^ Files
  -> Producer (Maybe Bool) (State m) ()
produceResults fs
  = for (each fs) instructions
  >-> procInstruction
  >-> procSpec
  >-> printTest

runAllTests
  :: MonadIO m
  => [BS8.ByteString]
  -- ^ Files
  -> State m Counts
runAllTests = totals . produceResults

runAndExit
  :: [BS8.ByteString]
  -> IO ()
runAndExit bs = do
  let st = runAllTests bs
  cts <- St.evalStateT st S.empty
  putStr . showCounts $ cts
  exit cts


data Counts = Counts
  { nPass :: !Int
  , nFail :: !Int
  , nSkip :: !Int
  } deriving Show

showCounts :: Counts -> String
showCounts (Counts p f s) = unlines
  [ "pass: " ++ show p
  , "fail: " ++ show f
  , "skip: " ++ show s
  , "total: " ++ show (p + f + s)
  ]

exit :: Counts -> IO ()
exit c
  | nFail c > 0 = exitFailure
  | otherwise = exitSuccess

showResult
  :: TestOutput
  -> BS8.ByteString
showResult (TestOutput t r sq) = BS8.unlines $ l1:lr
  where
    l1 = pf <+> showSpec t
    pf = case r of
      Nothing -> "[skip]"
      Just True -> "[pass]"
      Just False -> "[FAIL]"
    lr = map ("    " <>) . toList $ sq

showSpec :: P.TestSpec -> BS8.ByteString
showSpec t =
  P.testId t
  <+> P.testOperation t
  <+> BS8.concat (intersperse " " . P.testOperands $ t)
  <+> "->"
  <+> P.testResult t
  <+> BS8.concat (intersperse " " . P.testConditions $ t)

(<+>) :: BS8.ByteString -> BS8.ByteString -> BS8.ByteString
l <+> r
  | BS8.null l && BS8.null r = ""
  | BS8.null l || BS8.null r = l <> r
  | otherwise = l <> " " <> r

