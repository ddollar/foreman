## 0.37.0.pre5 2012-01-24 9632227
0.37.0.pre5  [David Dollar]
Merge pull request #142 from apollo13/master  [David Dollar]
rename readme  [David Dollar]
Fix the test for an empty string in bin/runner  [Florian Apolloner]

## 0.37.0.pre4 2012-01-24 a040324
0.37.0.pre4  [David Dollar]
Merge pull request #130 from clowder/foreman  [David Dollar]
Don't expose the options hash.  [Chris Lowder]
Simplify subclassing by adding all arguments to the initializer. Also, clean up the method signatures for existing exporters.  [Chris Lowder]
Add ZenTest as a development dependency, there is an autotest folder but the gem is missing.  [Chris Lowder]
Attempt to require the custom export class.  [Chris Lowder]
Catching more than we need to.  [Chris Lowder]
Extract commonality into the base class, make life easy for our plugin writers.  [Chris Lowder]
Removing the hard coding of export formats allowing the user to 'plug-in' their own export format.  [Chris Lowder]
Update README.markdown  [David Dollar]
Revert "try on more rubies"  [David Dollar]
try on more rubies  [David Dollar]
fix webhook url  [David Dollar]
Update README.markdown  [David Dollar]
Update README.markdown  [David Dollar]
ensure we have non-nil data, fixes #111  [David Dollar]
make sure error method exists. fixes #104  [David Dollar]
Merge pull request #136 from fnichol/foreman  [David Dollar]
remove other from install instructions  [David Dollar]
cleanup  [David Dollar]
Revert "tweak authors"  [David Dollar]
tweak authors  [David Dollar]
fix authors  [David Dollar]
readme tweaks  [David Dollar]
readme tweaks  [David Dollar]
fix up authors  [David Dollar]
Update README.markdown  [David Dollar]
fix up specs  [David Dollar]
we're not chdiring any more  [David Dollar]
use strings rather than symbols to better emulate the real thing  [David Dollar]
Merge pull request #139 from brainopia/foreman  [David Dollar]
Add specs for Foreman::Process#run  [brainopia]
Implement Foreman::Process#kill,detach,alive?,dead?  [brainopia]
- Use explicit fakefs tag in specs - Clean up trailing whitespace  [brainopia]
Simplify Foreman::Process#with_environment  [brainopia]
Add specs for options of Foreman::Process#run  [brainopia]
Add specs for initialization of Foreman::Process  [brainopia]
runit creates a full path to export directory.  [Fletcher Nichol]

## 0.37.0.pre3 2012-01-22 51eee01
0.37.0.pre3  [David Dollar]
normalize platform names  [David Dollar]
windows support  [David Dollar]
add windows support  [David Dollar]
dont need pty  [David Dollar]
fix specs  [David Dollar]

## 0.37.0.pre2 2012-01-22 2995a60
0.37.0.pre2  [David Dollar]
0.37.0.pre1  [David Dollar]
remove unnecessary stdout/stderr flattening  [David Dollar]
use PLATFORM=jruby instead of JRUBY=true  [David Dollar]

## 0.37.0.pre1 2012-01-22 3e98170
fix java build bug  [David Dollar]
dont do rubygems/bundler in the Rakefile  [David Dollar]
switch to posix-spawn for jruby  [David Dollar]
add jruby build  [David Dollar]
spork is in the gemspec now  [David Dollar]
remove debugging  [David Dollar]
move the spoon require into the jruby branch  [David Dollar]
pass basedir along to the runner script  [David Dollar]
beef up the runner script to allow a working directory to be set  [David Dollar]
Merge pull request #140 from jc00ke/foreman  [David Dollar]
Move spoon dep to Gemfile  [jc00ke]
Using spoon for JRuby support  [jc00ke]
use default bucket for storage  [David Dollar]
Merge pull request #138 from technomancy/debian  [David Dollar]
Add Debian packaging.  [Phil Hagelberg]
Ignore vendor dir.  [Phil Hagelberg]

## 0.36.1 2012-01-18 1485eeb
0.36.1  [David Dollar]
bump term-ansicolor in gemspec  [David Dollar]

## 0.36.0 2012-01-17 a73dce5
0.36.0  [David Dollar]
sync the writer stream  [David Dollar]
capture stderr as well  [David Dollar]

## 0.35.0 2012-01-16 2bfc065
update rake  [David Dollar]
0.35.0  [David Dollar]
Merge pull request #132 from Viximo/feature/concurrency  [David Dollar]
Fix export specs  [Matt Griffin]
Merge branch 'master' of https://github.com/michaeldwan/foreman into feature/concurrency  [Matt Griffin]
default process concurrency is 0 when concurrency options specified, otherwise default concurrency is 1  [Michael Dwan]

## 0.34.1 2012-01-16 d4c2332
0.34.1  [David Dollar]
fix missing start desc  [David Dollar]

## 0.34.0 2012-01-16 a278755
0.34.0  [David Dollar]
update man page  [David Dollar]
update docs for -d  [David Dollar]
Merge pull request #101 from ndbroadbent/foreman  [David Dollar]
Wrap around to the first colour when all the colours are used  [Craig R Webster]
run specs in random order  [David Dollar]
update rspec  [David Dollar]
pedantry  [David Dollar]
Set executable bit on runit run scripts.  [Matthijs Langenberg]
Merge pull request #114 from gburt/master  [David Dollar]
add more colors  [Gabriel Burt]
Added option to specify app_root, if executing a Procfile from a shared location  [Nathan Broadbent]

## 0.33.1 2012-01-16 533139e
0.33.1  [David Dollar]
Merge pull request #129 from fnichol/resolve-home-template  [David Dollar]
Expand template path under user's home directory.  [Fletcher Nichol]

## 0.33.0 2012-01-15 cf269c3
0.33.0  [David Dollar]
Revert "Merge pull request #125 from brainopia/master"  [David Dollar]

## 0.32.0 2012-01-12 83748cb
0.32.0  [David Dollar]
Merge pull request #125 from brainopia/master  [David Dollar]
Merge pull request #121 from Viximo/feature/run  [David Dollar]
Return some whitespace that was accidentally removed  [Matt Griffin]
Steal the run method back from Thor so that it can be used in place for exec for running commands in the foreman environment.  [Matt Griffin]
Remove old cruft  [brainopia]
In case someone wants to use bin/runner directly  [brainopia]
Fix for double fork  [brainopia]
Use ruby exec which works with escaped cmd and replaces shell  [brainopia]
Fix foreman to work with cmds containing pipes and redirects  [brainopia]
Add "exec" action to allow execution of arbitrary commands with the app's environment.  [Matt Griffin]
tweak readme  [David Dollar]

## 0.31.0 2012-01-04 342d30b
0.31.0  [David Dollar]
make fork more robust  [David Dollar]
remove unnecessary debug  [David Dollar]
add more information when shutting down  [David Dollar]
Merge pull request #110 from lstoll/master  [David Dollar]
Use different port ranges for each process type  [Lincoln Stoll]

## 0.30.1 2011-12-23 fcfa913
0.30.1  [David Dollar]
require thread for mutex  [David Dollar]

## 0.30.0 2011-12-22 fc95936
0.30.0  [David Dollar]
compatibility with ruby 1.8  [David Dollar]

## 0.29.0 2011-12-22 356c61f
0.29.0  [David Dollar]

## 0.28.0.pre2 2011-12-08 dcff4da
0.28.0.pre2  [David Dollar]
fix pipe error  [David Dollar]

## 0.28.0.pre1 2011-12-08 c7b6b33
0.28.0.pre1  [David Dollar]
Merge branch 'fork'  [David Dollar]
wip  [David Dollar]
wip  [David Dollar]
wip  [David Dollar]
wip  [David Dollar]
wip  [David Dollar]

## 0.27.0 2011-12-05 914a1ee
0.27.0  [David Dollar]
add changelog  [David Dollar]
Merge pull request #103 from csquared/load_env_from_irb  [David Dollar]
refactor load_env to apply_environment  [Chris Continanza]
rename load! to load_env!  [Chris Continanza]
use ./.env as default  [Chris Continanza]
load contents from env file  [Chris Continanza]
refactor engine to expose env methods  [Chris Continanza]
disable email notifications  [David Dollar]
add travis config  [David Dollar]

## 0.26.1 2011-12-05 a5e0943

Merge pull request #103 from csquared/load_env_from_irb   [David Dollar]
refactor load_env to apply_environment   [Chris Continanza]
rename load! to load_env!   [Chris Continanza]
use ./.env as default   [Chris Continanza]
load contents from env file   [Chris Continanza]
refactor engine to expose env methods   [Chris Continanza]
disable email notifications   [David Dollar]
add travis config   [David Dollar]
