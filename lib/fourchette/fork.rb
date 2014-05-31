class Fourchette::Fork
  include Fourchette::Logger

  def initialize params
    @params = params
    @heroku = Fourchette::Heroku.new
    @github = Fourchette::GitHub.new
  end

  def update
    create_unless_exists

    options = {
      source_blob: {
          url: @github.get_archive_link_for(branch_name)
        }
    }

    build = @heroku.client.build.create(fork_name, options)
    monitor_build(build)
  end

  def monitor_build build
    build_info = @heroku.client.build.info(fork_name, build['id'])
    while build_info['status'] == 'pending'
      build_info = @heroku.client.build.info(fork_name, build['id'])
      sleep 5
    end
    fail Fourchette::DeployException if build_info['status'] == 'failed'
  end

  def create
    @github.comment_pr(pr_number, "Fourchette is initializing a new fork.") if Fourchette::DEBUG
    create_unless_exists
    update
  end

  def delete
    @heroku.delete(fork_name)

    # Update PR with URL
    @github.comment_pr(pr_number, "Test app deleted!")
  end
  
  def fork_name
    "#{ENV['FOURCHETTE_HEROKU_APP_PREFIX']}-PR-#{pr_number}".downcase # It needs to be lowercase only.
  end

  def branch_name
    @params['pull_request']['head']['ref']
  end

  def pr_number
    @params['pull_request']['number']
  end

  private
  def create_unless_exists
    unless @heroku.app_exists?(fork_name)
      @heroku.fork(ENV['FOURCHETTE_HEROKU_APP_TO_FORK'] ,fork_name)
      # Update PR with URL
      @github.comment_pr(pr_number, "Test URL: #{@heroku.client.app.info(fork_name)['web_url']}")
    end
  end
end
