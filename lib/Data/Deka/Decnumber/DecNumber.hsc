{-# LANGUAGE ForeignFunctionInterface, OverloadedStrings #-}

#include <decNumber.h>
#include <decNumberMacros.h>
#let alignment t = "%lu", (unsigned long)offsetof(struct {char x__; t (y__); }, y__)

module Data.Deka.Decnumber.DecNumber where

import Control.Applicative
import Foreign.Safe
import Foreign.C
import Data.Deka.Decnumber.Context
import Data.Deka.Decnumber.Types
import Data.String

c'DECNAME :: IsString a => a
c'DECNAME = #const_str DECNAME

c'DECFULLNAME :: IsString a => a
c'DECFULLNAME = #const_str DECFULLNAME

c'DECAUTHOR :: IsString a => a
c'DECAUTHOR = #const_str DECAUTHOR

c'DECNEG :: Num a => a
c'DECNEG = #const DECNEG

c'DECINF :: Num a => a
c'DECINF = #const DECINF

c'DECNAN :: Num a => a
c'DECNAN = #const DECNAN

c'DECSNAN :: Num a => a
c'DECSNAN = #const DECSNAN

c'DECSPECIAL :: Num a => a
c'DECSPECIAL = #const DECSPECIAL

c'DECDPUN :: Num a => a
c'DECDPUN = #const DECDPUN

c'DECNUMDIGITS :: Num a => a
c'DECNUMDIGITS = #const DECNUMDIGITS

c'DECNUMUNITS :: Num a => a
c'DECNUMUNITS = #const DECNUMUNITS

type C'decNumberUnit = #type decNumberUnit

data C'decNumber = C'decNumber
  { c'decNumber'digits :: C'int32_t
  , c'decNumber'exponent :: C'int32_t
  , c'decNumber'bits :: C'uint8_t
  , c'decNumber'lsu :: [C'decNumberUnit]
  } deriving (Eq, Show)

instance Storable C'decNumber where
  sizeOf _ = #size decNumber
  alignment _ = #alignment decNumber
  peek p =
    C'decNumber
    <$> #{peek decNumber, digits} p
    <*> #{peek decNumber, exponent} p
    <*> #{peek decNumber, bits} p
    <*> peekArray c'DECNUMUNITS (#{ptr decNumber, lsu} p)

  poke p (C'decNumber ds ex bs ls) =
    #{poke decNumber, digits} p ds
    >> #{poke decNumber, exponent} p ex
    >> #{poke decNumber, bits} p bs
    >> pokeArray (#{ptr decNumber, lsu} p) ls


foreign import ccall unsafe "decNumberFromInt32" c'decNumberFromInt32
  :: Ptr C'decNumber
  -> C'int32_t
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberFromUInt32" c'decNumberFromUInt32
  :: Ptr C'decNumber
  -> C'uint32_t
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberFromString" c'decNumberFromString
  :: Ptr C'decNumber
  -> CString
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberToString" c'decNumberToString
  :: Ptr C'decNumber
  -> CString
  -> CString

foreign import ccall unsafe "decNumberToEngString" c'decNumberToEngString
  :: Ptr C'decNumber
  -> CString
  -> CString

foreign import ccall unsafe "decNumberToUInt32" c'decNumberToUInt32
  :: Ptr C'decNumber
  -> Ptr C'decContext
  -> C'uint32_t

foreign import ccall unsafe "decNumberToInt32" c'decNumberToInt32
  :: Ptr C'decNumber
  -> Ptr C'decContext
  -> C'int32_t

foreign import ccall unsafe "decNumberGetBCD" c'decNumberGetBCD
  :: Ptr C'decNumber
  -> Ptr C'uint8_t
  -> Ptr C'uint8_t

foreign import ccall unsafe "decNumberSetBCD" c'decNumberSetBCD
  :: Ptr C'decNumber
  -> Ptr C'uint8_t
  -> C'uint32_t
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberAbs" c'decNumberAbs
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberAdd" c'decNumberAdd
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberAnd" c'decNumberAnd
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCompare" c'decNumberCompare
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCompareSignal" c'decNumberCompareSignal
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCompareTotal" c'decNumberCompareTotal
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCompareTotalMag" c'decNumberCompareTotalMag
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberDivide" c'decNumberDivide
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberDivideInteger" c'decNumberDivideInteger
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberExp" c'decNumberExp
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberFMA" c'decNumberFMA
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberInvert" c'decNumberInvert
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberLn" c'decNumberLn
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberLogB" c'decNumberLogB
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberLog10" c'decNumberLog10
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberMax" c'decNumberMax
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberMaxMag" c'decNumberMaxMag
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberMin" c'decNumberMin
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberMinMag" c'decNumberMinMag
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberMinus" c'decNumberMinus
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberMultiply" c'decNumberMultiply
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberNormalize" c'decNumberNormalize
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberOr" c'decNumberOr
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberPlus" c'decNumberPlus
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberPower" c'decNumberPower
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberQuantize" c'decNumberQuantize
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberReduce" c'decNumberReduce
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberRemainder" c'decNumberRemainder
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberRemainderNear" c'decNumberRemainderNear
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberRescale" c'decNumberRescale
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberRotate" c'decNumberRotate
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberSameQuantum" c'decNumberSameQuantum
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberScaleB" c'decNumberScaleB
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberShift" c'decNumberShift
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberSquareRoot" c'decNumberSquareRoot
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberSubtract" c'decNumberSubtract
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberToIntegralExact" c'decNumberToIntegralExact
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberToIntegralValue" c'decNumberToIntegralValue
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberXor" c'decNumberXor
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberClass" c'decNumberClass
  :: Ptr C'decNumber
  -> Ptr C'decContext
  -> C'decClass

foreign import ccall unsafe "decNumberClassToString" c'decNumberClassToString
  :: C'decClass
  -> CString

foreign import ccall unsafe "decNumberCopy" c'decNumberCopy
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCopyAbs" c'decNumberCopyAbs
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCopyNegate" c'decNumberCopyNegate
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberCopySign" c'decNumberCopySign
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberNextMinus" c'decNumberNextMinus
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberNextPlus" c'decNumberNextPlus
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberNextToward" c'decNumberNextToward
  :: Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decNumber
  -> Ptr C'decContext
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberTrim" c'decNumberTrim
  :: Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberVersion" c'decNumberVersion
  :: CString

foreign import ccall unsafe "decNumberZero" c'decNumberZero
  :: Ptr C'decNumber
  -> Ptr C'decNumber

foreign import ccall unsafe "decNumberIsNormal" c'decNumberIsNormal
  :: Ptr C'decNumber
  -> Ptr C'decContext
  -> C'int32_t

foreign import ccall unsafe "decNumberIsSubnormal" c'decNumberIsSubnormal
  :: Ptr C'decNumber
  -> Ptr C'decContext
  -> C'int32_t

foreign import ccall unsafe "m_decNumberIsCanonical" c'decNumberIsCanonical
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsFinite" c'decNumberIsFinite
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsInfinite" c'decNumberIsInfinite
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsNaN" c'decNumberIsNaN
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsNegative" c'decNumberIsNegative
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsQNaN" c'decNumberIsQNaN
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsSNaN" c'decNumberIsSNaN
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsSpecial" c'decNumberIsSpecial
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberIsZero" c'decNumberIsZero
  :: Ptr C'decNumber
  -> CInt

foreign import ccall unsafe "m_decNumberRadix" c'decNumberRadix
  :: Ptr C'decNumber
  -> CInt

