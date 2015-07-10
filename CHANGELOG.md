--------------------------------------------------------------------------------
                        ^ ADD NEW CHANGES ABOVE ^
--------------------------------------------------------------------------------

CHANGELOG
=========

---- 0.0.2 / 2014-09-11 / configuration ----------------------------------------
* configurable aws creds and simpledb url

---- 0.0.3 / 2014-09-12 / docs-and-tests ---------------------------------------
* set up travis/coveralls

---- 0.0.4 / 2014-09-13 / readme -----------------------------------------------
* update readme

---- 0.1.0 / 2014-09-13 / ------------------------------------------------------
* initial release to hex.pm

---- 0.1.2 / 2014-09-17 / metadata-credentials ---------------------------------
* retrieve access keys from IAM roles when running in EC2

---- 0.1.3 / 2014-09-17 / refactor-config --------------------------------------
* allow multiple configs instead of one global config

---- 0.2.3 / 2014-09-18 / token ------------------------------------------------
* fix IAM credentials by including token

---- 0.2.5 / 2014-09-23 / configurable-version ---------------------------------
* allow configuration of simpledb version

---- 0.2.6 / 2014-10-09 / retry-on-error ---------------------------------------
* retry with exponential backoff for 500 errors

---- 0.2.7 / 2014-10-15 / update-httpoison -------------------------------------
* update httpoison

---- 0.2.8 / 2014-12-08 / httpotion --------------------------------------------
* switch to httpotion / ibrowse

---- 0.2.10 / 2015-04-01 / retry-httpotion-errors ------------------------------
* retry errors, upgrade httpotion, remove exvcr test dependency

---- 0.3.1 / 2015-07-10 / fix-key-refresh-date-comparison ----------------------
* fix date comparison that determines when aws creds need refreshing
