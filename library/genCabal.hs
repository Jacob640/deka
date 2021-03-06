-- Generate Cabal file using Cartel.
-- Written for Cartel version 0.10.0.2.
module Main where

import qualified CabalCommon as CC
import qualified Cartel as C

properties :: C.Properties
properties = CC.properties
  { C.prName = "deka"
  , C.prSynopsis = "Decimal floating point arithmetic"
  , C.prDescription = CC.description ++
    [ "Tests are packaged separately in the deka-tests package."
    ]
  }

library
  :: [String]
  -- ^ Exposed modules
  -> [String]
  -- ^ Internal modules
  -> C.Library
library ex hd = C.Library
  [ C.LibExposedModules ex
  , C.otherModules hd
  , C.hsSourceDirs ["exposed", "internal"]
  , C.buildDepends $ CC.buildDeps ++
    [ CC.parsec
    , CC.transformers
    ]
  , C.ghcOptions CC.ghcOptions
  , C.defaultLanguage C.Haskell2010
  , C.extraLibraries ["mpdec"]
  ]

cabal
  :: [String]
  -- ^ Exposed modules
  -> [String]
  -- ^ Internal modules
  -> C.Cabal

cabal ex hd = C.empty
  { C.cProperties = properties
  , C.cRepositories = [CC.repo]
  , C.cLibrary = Just $ library ex hd
  }

main :: IO ()
main = do
  ex <- C.modules "exposed"
  hd <- C.modules "internal"
  C.render "genCabal.hs" $ cabal ex hd
