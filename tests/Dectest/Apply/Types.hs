module Dectest.Apply.Types where

import qualified Data.ByteString.Char8 as BS8
import qualified Deka.Context as C
import Dectest.Interp.Octothorpe (WhichPrecision)
import Data.Functor.Identity

data Bypass
  = Skip
  -- ^ No suitable test for this operation; skip the test
  | Null
  -- ^ One of the operands was null; skip the test
  | Fail BS8.ByteString [C.Flag]
  -- ^ Comes with the string representation of the test result
  | OperandMismatch
  -- ^ Test did not come with right number of operands
  deriving Show

data Directives a = Directives
  { precision :: a C.Precision
  , rounding :: a C.Round
  , emax :: a C.Emax
  , emin :: a C.Emin
  , extended :: Bool
  , clamp :: Bool
  }

blankDirectives :: Directives Maybe
blankDirectives = Directives
  { precision = Nothing
  , rounding = Nothing
  , emax = Nothing
  , emin = Nothing
  , extended = True
  , clamp = False
  }

setDirectives :: Directives Maybe -> Directives Identity
setDirectives d = Directives
  { precision = f "precision" . precision $ d
  , rounding = f "rounding" . rounding $ d
  , emax = f "emax" . emax $ d
  , emin = f "emin" . emin $ d
  , extended = extended d
  , clamp = clamp d
  }
  where
    f desc = maybe (error $ "required directive " ++ desc
      ++ "not set") Identity

type ApplyTest a
  = [WhichPrecision -> C.Ctx a]
  -- ^ Operands
  -> Maybe (C.Ctx (BS8.ByteString, BS8.ByteString -> Maybe (C.Ctx Bool)))
  -- ^ Return Nothing if there is an operand type mismatch;
  -- otherwise, return the result of the function.  The result is a
  -- pair.  The first element of the pair is how to show the result.
  -- The second element, when applied to the token for the target
  -- result, returns a Maybe which is Nothing if the target result
  -- is Null or Just with a computation if the target result is not
  -- null.  That computation returns the result of the test.
