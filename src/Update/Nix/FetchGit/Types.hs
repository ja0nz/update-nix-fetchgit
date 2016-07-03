{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Update.Nix.FetchGit.Types where

import           Data.Data             (Data)
import           Data.Functor.Compose
import           Data.Text             (Text)
import           Data.Typeable         (Typeable)
import           Nix.Expr              (NExprLoc)

-- TODO: Remove when using base 4.9, necessary at the moment because Compose
-- doesn't have a data declaration
deriving instance (Typeable f, Typeable g, Typeable a, Data (f (g a)))
  => Data (Compose f g a)

-- | A tree with a structure similar to the AST of the Nix file we are
-- parsing, but which only contains the information we care about.
-- The fetchInfo type parameter allows this tree to be used at
-- different stages in the program where we know different amounts of
-- information about a fetch expression.
data FetchTree fetchInfo = Node { nodeVersionExpr :: Maybe NExprLoc
                                , nodeChildren    :: [FetchTree fetchInfo]
                                }
                         | FetchNode fetchInfo
  deriving (Show, Data, Functor, Foldable, Traversable)

-- | Represents the arugments to a call to fetchgit or fetchFromGitHub
--   as parsed from a .nix file.
data FetchGitArgs = FetchGitArgs { repoLocation :: RepoLocation
                                 , revExpr      :: NExprLoc
                                 , sha256Expr   :: NExprLoc
                                 }
  deriving (Show, Data)

-- | Updated information about a fetchgit call that was retrieved from
-- the internet.
data FetchGitLatestInfo = FetchGitLatestInfo { originalInfo :: FetchGitArgs
                                             , latestRev    :: Text
                                             , latestSha256 :: Text
                                             }
  deriving (Show, Data)

-- | A repo is either specified by URL or by Github owner/repo.
data RepoLocation = URL Text
                  | GitHub { owner :: Text
                           , repo  :: Text
                           }
  deriving (Show, Data)
