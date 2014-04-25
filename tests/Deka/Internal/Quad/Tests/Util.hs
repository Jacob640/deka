-- | Test utilities

module Deka.Internal.Quad.Tests.Util where

import Deka.Internal.Context
import Deka.Internal.Context.Generators
import Deka.Internal.Decnumber.DecQuad
import Deka.Internal.Quad.Quad
import Deka.Internal.Quad.Decoding
import Deka.Internal.Quad.Decoding.Generators
import Foreign.Safe
import qualified Data.ByteString as BS
import Test.QuickCheck
import Test.Tasty.QuickCheck (testProperty)
import Test.Tasty (testGroup, TestTree)
import Test.QuickCheck.Monadic
import Prelude hiding (round)

-- | Verify that the contents of a Quad did not change.

noChange
  :: Quad
  -- ^ Quad to inspect
  -> IO a
  -- ^ Run this IO action after initial inspection of the quad
  -> IO Bool
  -- ^ True if the Quad did NOT change after running the IO action.
  -- False if the Quad changed.
noChange q a =
  withForeignPtr (unQuad q) $ \ptr ->
  BS.packCStringLen (castPtr ptr, c'decQuad'sizeOf) >>= \before ->
  a >>
  BS.packCStringLen (castPtr ptr, c'decQuad'sizeOf) >>= \after ->
  return (before == after)

pNoChange :: Quad -> IO a -> Property
pNoChange q a = monadicIO $ do
  r <- run $ noChange q a
  assert r

-- | Unary function does not change first argument
unaryCF
  :: (Quad -> IO a)
  -> TestTree
unaryCF f = testProperty desc test
  where
    desc = "unary function - does not change only argument"
    test = forAll genDecoded $ \dcd -> monadicIO $ do
      q <- run $ fromBCD dcd
      r <- run $ noChange q (f q)
      assert r

binaryCF
  :: (Quad -> Quad -> IO a)
  -> TestTree
binaryCF f = testGroup desc tests
  where
    desc = "binary function - does not change argument:"
    tests = [ testProperty "first" t1, testProperty "second" t2]
    t1 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      monadicIO $
      run (fromBCD dcd1) >>= \q1 ->
      run (fromBCD dcd2) >>= \q2 ->
      run (noChange q1 (f q1 q2)) >>=
      assert

    t2 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      monadicIO $
      run (fromBCD dcd1) >>= \q1 ->
      run (fromBCD dcd2) >>= \q2 ->
      run (noChange q2 (f q1 q2)) >>=
      assert

ternaryCF
  :: (Quad -> Quad -> Quad -> IO a)
  -> TestTree
ternaryCF f = testGroup desc tests
  where
    desc = "ternary function - does not change argument:"
    tests = [ testProperty "first" t1, testProperty "second" t2,
              testProperty "third" t3]
    t1 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll genDecoded $ \dcd3 ->
      monadicIO $
      run (fromBCD dcd1) >>= \q1 ->
      run (fromBCD dcd2) >>= \q2 ->
      run (fromBCD dcd3) >>= \q3 ->
      run (noChange q1 (f q1 q2 q3)) >>=
      assert

    t2 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll genDecoded $ \dcd3 ->
      monadicIO $
      run (fromBCD dcd1) >>= \q1 ->
      run (fromBCD dcd2) >>= \q2 ->
      run (fromBCD dcd3) >>= \q3 ->
      run (noChange q2 (f q1 q2 q3)) >>=
      assert

    t3 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll genDecoded $ \dcd3 ->
      monadicIO $
      run (fromBCD dcd1) >>= \q1 ->
      run (fromBCD dcd2) >>= \q2 ->
      run (fromBCD dcd3) >>= \q3 ->
      run (noChange q3 (f q1 q2 q3)) >>=
      assert


unary
  :: (Quad -> Ctx a)
  -> TestTree
unary fn = testProperty desc tst
  where
    desc = "unary function - does not change only argument"
    tst = forAll genDecoded $ \dcd ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd >>= \q ->
            noChange q (unCtx (fn q) ptr)) >>=
      assert

binary
  :: (Quad -> Quad -> Ctx a)
  -> TestTree
binary fn = testGroup desc tsts
  where
    desc = "binary function - does not change argument:"
    tsts = [ testProperty "first" t1, testProperty "second" t2 ]

    t1 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd1 >>= \q1 ->
            fromBCD dcd2 >>= \q2 ->
            noChange q1 (unCtx (fn q1 q2) ptr)) >>=
      assert

    t2 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd1 >>= \q1 ->
            fromBCD dcd2 >>= \q2 ->
            noChange q2 (unCtx (fn q1 q2) ptr)) >>=
      assert

ternary
  :: (Quad -> Quad -> Quad -> Ctx a)
  -> TestTree
ternary fn = testGroup desc tsts
  where
    desc = "ternary function - does not change argument:"
    tsts = [ testProperty "first" t1, testProperty "second" t2,
             testProperty "third" t3 ]

    t1 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll genDecoded $ \dcd3 ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd1 >>= \q1 ->
            fromBCD dcd2 >>= \q2 ->
            fromBCD dcd3 >>= \q3 ->
            noChange q1 (unCtx (fn q1 q2 q3) ptr)) >>=
      assert

    t2 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll genDecoded $ \dcd3 ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd1 >>= \q1 ->
            fromBCD dcd2 >>= \q2 ->
            fromBCD dcd3 >>= \q3 ->
            noChange q2 (unCtx (fn q1 q2 q3) ptr)) >>=
      assert

    t3 = forAll genDecoded $ \dcd1 ->
      forAll genDecoded $ \dcd2 ->
      forAll genDecoded $ \dcd3 ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd1 >>= \q1 ->
            fromBCD dcd2 >>= \q2 ->
            fromBCD dcd3 >>= \q3 ->
            noChange q3 (unCtx (fn q1 q2 q3) ptr)) >>=
      assert

rounded
  :: (Round -> Quad -> Ctx a)
  -> TestTree
rounded fn = testProperty desc tst
  where
    desc = "rounded: does not change only Quad argument"
    tst = forAll round $ \r ->
      forAll genDecoded $ \dcd ->
      forAll (fmap Blind context) $ \(Blind ioCtx) ->
      monadicIO $
      run ioCtx >>= \fp ->
      run ( withForeignPtr fp $ \ptr ->
            fromBCD dcd >>= \q ->
            noChange q (unCtx (fn r q) ptr)) >>=
      assert