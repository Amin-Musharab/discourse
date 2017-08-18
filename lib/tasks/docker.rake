# rake docker:test is designed to be used inside the discourse/docker_test image
# running it anywhere else will likely fail
#
# Environment Variables (specific to this rake task)
# => SKIP_CORE                 set to 1 to skip core tests (rspec and qunit)
# => SKIP_PLUGINS              set to 1 to skip plugin tests (rspec and qunit)
# => INSTALL_OFFICIAL_PLUGINS  set to 1 to install all core plugins before running tests
# => RUBY_ONLY                 set to 1 to skip all qunit tests
# => JS_ONLY                   set to 1 to skip all rspec tests
# => SINGLE_PLUGIN             set to plugin name to only run plugin-specific rspec tests (you'll probably want to SKIP_CORE as well)
# => BISECT                    set to 1 to run rspec --bisect (applies to core rspec tests only)
# => RSPEC_SEED                set to seed to use for rspec tests (applies to core rspec tests only)
#
# Other useful environment variables (not specific to this rake task)
# => COMMIT_HASH    used by the discourse_test docker image to load a specific commit of discourse
#                   this can also be set to a branch, e.g. "origin/tests-passed"
#
# Example usage:
#   Run all core and plugin tests:
#       docker run discourse/discourse_test:release
#   Run only rspec tests:
#       docker run -e RUBY_ONLY=1 discourse/discourse_test:release
#   Run all plugin tests (with a plugin mounted from host filesystem):
#       docker run -e SKIP_CORE=1 -v $(pwd)/my-awesome-plugin:/var/www/discourse/plugins/my-awesome-plugin discourse/discourse_test:release
#   Run tests for a specific plugin (with a plugin mounted from host filesystem):
#       docker run -e SKIP_CORE=1 SINGLE_PLUGIN='my-awesome-plugin' -v $(pwd)/my-awesome-plugin:/var/www/discourse/plugins/my-awesome-plugin discourse/discourse_test:release

def run_or_fail(command)
  pid = Process.spawn(command)
  Process.wait(pid)
  $?.exitstatus == 0
end

desc 'Run JS and Ruby linters'
task 'docker:lint' do
  success = run_or_fail("bundle exec rubocop --parallel")
  success = run_or_fail("eslint app/assets/javascripts test/javascripts")
  success = run_or_fail("eslint --ext .es6 app/assets/javascripts test/javascripts plugins")

  exit 1 if !success
end

desc 'Run all tests (JS and code in a standalone environment)'
task 'docker:test' do
  begin

    puts "Cleaning up old test tmp data in tmp/test_data"
    `rm -fr tmp/test_data && mkdir -p tmp/test_data/redis && mkdir tmp/test_data/pg`

    puts "Starting background redis"
    @redis_pid = Process.spawn('redis-server --dir tmp/test_data/redis')

    @postgres_bin = "/usr/lib/postgresql/9.5/bin/"
    `#{@postgres_bin}initdb -D tmp/test_data/pg`

    # speed up db, never do this in production mmmmk
    `echo fsync = off >> tmp/test_data/pg/postgresql.conf`
    `echo full_page_writes = off >> tmp/test_data/pg/postgresql.conf`
    `echo shared_buffers = 500MB >> tmp/test_data/pg/postgresql.conf`

    puts "Starting postgres"
    @pg_pid = Process.spawn("#{@postgres_bin}postmaster -D tmp/test_data/pg")

    ENV["RAILS_ENV"] = "test"

    @good = run_or_fail("bundle exec rake db:create db:migrate")

    if ENV["INSTALL_OFFICIAL_PLUGINS"]
      @good &&= run_or_fail("bundle exec rake plugin:install_all_official")
    end

    unless ENV["JS_ONLY"]

      unless ENV["SKIP_CORE"]
        params = []
        if ENV["BISECT"]
          params << "--bisect"
        end
        if ENV["RSPEC_SEED"]
          params << "--seed #{ENV["RSPEC_SEED"]}"
        end
        @good &&= run_or_fail("bundle exec rspec #{params.join(' ')}".strip)
      end

      unless ENV["SKIP_PLUGINS"]
        if ENV["SINGLE_PLUGIN"]
          @good &&= run_or_fail("bundle exec rake plugin:spec['#{ENV["SINGLE_PLUGIN"]}']")
        else
          @good &&= run_or_fail("bundle exec rake plugin:spec")
        end
      end

    end

    unless ENV["RUBY_ONLY"]
      unless ENV["SKIP_CORE"]
        @good &&= run_or_fail("bundle exec rake qunit:test['600000']")
        @good &&= run_or_fail("bundle exec rake qunit:test['600000','/wizard/qunit']")
      end

      unless ENV["SKIP_PLUGINS"]
        if ENV["SINGLE_PLUGIN"]
          @good &&= run_or_fail("bundle exec rake plugin:qunit['#{ENV['SINGLE_PLUGIN']}','600000']")
        else
          @good &&= run_or_fail("bundle exec rake plugin:qunit['*','600000']")
        end
      end

    end

  ensure
    puts "Terminating"

    Process.kill("TERM", @redis_pid)
    Process.kill("TERM", @pg_pid)
    Process.wait @redis_pid
    Process.wait @pg_pid
  end

  if !@good
    exit 1
  end

end
