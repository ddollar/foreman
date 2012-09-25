## 0.60.0 (2012-09-25)

* foreman run can run things from the Procfile like heroku run.  [Dan Peterson]

## 0.59.0 (2012-09-15)

* Use /bin/sh instead of bash for foreman-runner  [Jeremy Evans]

## 0.58.0 (2012-09-14)

* dont set HOME  [David Dollar]
* Add StandardOutPath to launchd export  [Aaron Kalin]
* Add command argument string splitting  [Aaron Kalin]
* Cleanup launchd exporter  [Aaron Kalin]
* Enable trim_mode via '-' in ERB templates  [Aaron Kalin]
* Add support for setting environment variables  [Aaron Kalin]
* foreman run should exit with the same code as its command  [Omar Khan]
* Handle multiline strings in .env file  [Szymon Nowak]
* Use path and env variables in the inittab export  [Indrek Juhkam]
* fixed the directory option  [Arnaud Lachaume]
* Add capistrano export support  [Daniel Farrell]

## 0.57.0 (2012-08-21)

* fix startup checks for upstart exporter  [Aditya Sanghi]

## 0.56.0 (2012-08-19)

* read .profile, not .profile.d  [David Dollar]

## 0.55.0 (2012-08-14)

* use a forked process to exec a run with environment  [David Dollar]

## 0.54.0 (2012-08-14)

* use Foreman::Process to extract command running  [David Dollar]
* changed to check env for bash  [brntbeer]

## 0.53.0 (2012-07-24)

* put app root in $HOME  [David Dollar]

## 0.52.0 (2012-07-24)

* wrap command in a runner that sources .profile.d scripts  [David Dollar]
* fix upstart export specs  [David Dollar]
* Make upstart export start/stop with network  [Daniel Farrell]

## 0.51.0 (2012-07-11)

* dont try to colorize windows  [David Dollar]

## 0.50.0 (2012-07-11)

* handle windows  [David Dollar]

## 0.49.0 (2012-07-11)

* 1.8 compatibility  [David Dollar]
* use one pgroup for all of foreman and kill that since ruby 1.8 sucks at pgroups  [David Dollar]
* better debugging  [David Dollar]

## 0.48.0 (2012-07-10)

* allow old exporter format to work, but with deprecation warning  [David Dollar]
* remove debugging code  [David Dollar]
* Merge pull request #219 from MarkDBlackwell/patch-1  [David Dollar]
* Avoid crash by verifying the existence of SIGHUP before accessing it.  [Mark D. Blackwell]
* allow color to be forced on  [David Dollar]
* terminate gracefully if stdout goes away  [David Dollar]
* always flush output  [David Dollar]
* Merge pull request #212 from morgoth/added-version-command  [David Dollar]
* added command for displaying foreman version  [Wojciech Wnętrzak]
* Merge pull request #211 from morgoth/fixed-yaml-usage  [David Dollar]
* fixed using YAML  [Wojciech Wnętrzak]
* test on more things, but don't fail  [David Dollar]
* changelog  [David Dollar]
* 0.48.0.pre1  [David Dollar]
* foreman doesn't work on ruby 1.8, may try to fix later  [David Dollar]
* use bash  [David Dollar]
* massive refactoring for programmatic control and stability  [David Dollar]
* Merge pull request #164 from hsume2/master  [David Dollar]
* Only run tmux specs if tmux is installed  [Henry Hsu]
* Do not assume BUNDLE_GEMFILE  [Henry Hsu]
* Add support for starting procfile in tmux session  [Henry Hsu]

## 0.47.0 (2012-06-07)

* Fix multi-word argument handling in `foreman run`.  [Daniel Brockman]
* Make 'PORT=5000 foreman start' work  [Koen Van der Auwera]
* Terminate gracefully upon SIGHUP  [Stefan Schüßler]
* Set port from .env if specified  [Koen Van der Auwera]
* Updated bluepill exporter to use environment variables from .env  [Aneeth]
* Added launchd exporter  [Maxwell Swadling]
* Quote and escape environment variables in upstart templates  [Matt Griffin]
* Added list of ports to other languages to README  [elf Pavlik]

## 0.46.0 (2012-05-02)

* Add Profile load/write/append API  [Michael Granger]
* Guard against missing Procfile in engine.rb  [Brian Kaney]

## 0.45.0 (2012-04-26)

* create and chown log dir in upstart export.  [Phil Hagelberg]
* remove parka from dist files  [David Dollar]

## 0.44.0 (2012-04-23)

* make var output order repeatable in supervisord export [David Dollar]
* make --procfile and --app-root influence each other in a more intuitive way  [David Dollar]
* Look for .env and app_root in the same dir as the Procfile.  [Phil Hagelberg]

## 0.43.0 (2012-04-20)

* wrap supervisord env vars in quotes  [Raphael Randschau]

## 0.42.0 (2012-04-18)

* Move read_environment to a public class method.  [Phil Hagelberg]
* Drop parka dependency  [Phil Hagelberg]
* add group support for supervisord  [Raphael Randschau]
* fix enviroment export  [Raphael Randschau]

## 0.41.0 (2012-03-16)

* replace term-ansicolor with built-in colorization  [David Dollar]
* supervisord export template  [Raphael Randschau]

## 0.40.0 (2012-02-24)

* support various quoting styles in .env  [David Dollar]
* remove load_env! as it's made unnecessary by foreman run  [David Dollar]
* Provide a useful error if `foreman check` fails to find a Procfile  [R. Tyler Croy]
* update docs  [David Dollar]

## 0.39.0 (2012-02-07)

* rename bin/runner to bin/foreman-runner  [David Dollar]
* fix tgz release  [David Dollar]
* bundle update hpricot  [John Firebaugh]
* touch up .pkg release tasks  [David Dollar]

## 0.38.0 (2012-02-02)

* bring back single process starting  [David Dollar]
* more attempts at getting ci working with jruby  [David Dollar]
* ignore .rbenv-version  [David Dollar]
* force to binary encoding if supported  [David Dollar]

## 0.37.2 (2012-01-29)

* handle directories with spaces in runner  [David Dollar]
* update docs  [David Dollar]

## 0.37.1 (2012-01-29)

* use binary pipes to better handle UTF-8 data  [David Dollar]
* set up example procfile with UTF-8 item  [David Dollar]
* remove autotest  [David Dollar]
* fix up authors generation  [David Dollar]
* fix up packaging after moving tasks  [David Dollar]
* fix up changelog tasks  [David Dollar]

## 0.37.0 (2012-01-29)

* put an entire line of output inside a single mutex so we don't cross the streams  [David Dollar]
* fix race condition with process termination  [David Dollar]
* allow external custom exporters [Chris Lowder]
* fix the test for an empty string in bin/runner  [Florian Apolloner]
* ensure we have non-nil data, fixes #111  [David Dollar]
* make sure error method exists, fixes #104  [David Dollar]
* clean up chdir usage  [David Dollar]
* normalize platform names  [David Dollar]
* add windows support  [David Dollar]
* add jruby support  [David Dollar]
* pass basedir along to the runner script  [David Dollar]
* harden runner script  [David Dollar]
* add many missing specs  [brainopia]
* clean up fakefs usage in specs  [brainopia]
* runit creates a full path to export directory.  [Fletcher Nichol]

## 0.36.1 (2012-01-18)

* 0.36.1  [David Dollar]
* bump term-ansicolor in gemspec  [David Dollar]

## 0.36.0 (2012-01-17)

* 0.36.0  [David Dollar]
* sync the writer stream  [David Dollar]
* capture stderr as well  [David Dollar]

## 0.35.0 (2012-01-16)

* update rake  [David Dollar]
* 0.35.0  [David Dollar]
* Merge pull request #132 from Viximo/feature/concurrency  [David Dollar]
* Fix export specs  [Matt Griffin]
* Merge branch 'master' of https://github.com/michaeldwan/foreman into feature/concurrency  [Matt Griffin]
* default process concurrency is 0 when concurrency options specified, otherwise default concurrency is 1  [Michael Dwan]

## 0.34.1 (2012-01-16)

* 0.34.1  [David Dollar]
* fix missing start desc  [David Dollar]

## 0.34.0 (2012-01-16)

* 0.34.0  [David Dollar]
* update man page  [David Dollar]
* update docs for -d  [David Dollar]
* Merge pull request #101 from ndbroadbent/foreman  [David Dollar]
* Wrap around to the first colour when all the colours are used  [Craig R Webster]
* run specs in random order  [David Dollar]
* update rspec  [David Dollar]
* pedantry  [David Dollar]
* Set executable bit on runit run scripts.  [Matthijs Langenberg]
* Merge pull request #114 from gburt/master  [David Dollar]
* add more colors  [Gabriel Burt]
* Added option to specify app_root, if executing a Procfile from a shared location  [Nathan Broadbent]

## 0.33.1 (2012-01-16)

* 0.33.1  [David Dollar]
* Merge pull request #129 from fnichol/resolve-home-template  [David Dollar]
* Expand template path under user's home directory.  [Fletcher Nichol]

## 0.33.0 (2012-01-15)

* 0.33.0  [David Dollar]
* Revert "Merge pull request #125 from brainopia/master"  [David Dollar]

## 0.32.0 (2012-01-12)

* 0.32.0  [David Dollar]
* Merge pull request #125 from brainopia/master  [David Dollar]
* Merge pull request #121 from Viximo/feature/run  [David Dollar]
* Return some whitespace that was accidentally removed  [Matt Griffin]
* Steal the run method back from Thor so that it can be used in place for exec for running commands in the foreman environment.  [Matt Griffin]
* Remove old cruft  [brainopia]
* In case someone wants to use bin/runner directly  [brainopia]
* Fix for double fork  [brainopia]
* Use ruby exec which works with escaped cmd and replaces shell  [brainopia]
* Fix foreman to work with cmds containing pipes and redirects  [brainopia]
* Add "exec" action to allow execution of arbitrary commands with the app's environment.  [Matt Griffin]
* tweak readme  [David Dollar]

## 0.31.0 (2012-01-04)

* 0.31.0  [David Dollar]
* make fork more robust  [David Dollar]
* remove unnecessary debug  [David Dollar]
* add more information when shutting down  [David Dollar]
* Merge pull request #110 from lstoll/master  [David Dollar]
* Use different port ranges for each process type  [Lincoln Stoll]

## 0.30.1 (2011-12-23)

* 0.30.1  [David Dollar]
* require thread for mutex  [David Dollar]

## 0.30.0 (2011-12-22)

* 0.30.0  [David Dollar]
* compatibility with ruby 1.8  [David Dollar]

## 0.29.0 (2011-12-22)

* 0.29.0  [David Dollar]
* 0.28.0.pre2  [David Dollar]
* fix pipe error  [David Dollar]
* 0.28.0.pre1  [David Dollar]
* Merge branch 'fork'  [David Dollar]
* wip  [David Dollar]
* wip  [David Dollar]
* wip  [David Dollar]
* wip  [David Dollar]
* wip  [David Dollar]

## 0.27.0 (2011-12-05)

* 0.27.0  [David Dollar]
* add changelog  [David Dollar]
* Merge pull request #103 from csquared/load_env_from_irb  [David Dollar]
* refactor load_env to apply_environment  [Chris Continanza]
* rename load! to load_env!  [Chris Continanza]
* use ./.env as default  [Chris Continanza]
* load contents from env file  [Chris Continanza]
* refactor engine to expose env methods  [Chris Continanza]
* disable email notifications  [David Dollar]
* add travis config  [David Dollar]

## 0.26.1 2011-12-05

* Merge pull request #103 from csquared/load_env_from_irb   [David Dollar]
* refactor load_env to apply_environment   [Chris Continanza]
* rename load! to load_env!   [Chris Continanza]
* use ./.env as default   [Chris Continanza]
* load contents from env file   [Chris Continanza]
* refactor engine to expose env methods   [Chris Continanza]
* disable email notifications   [David Dollar]
* add travis config   [David Dollar]
