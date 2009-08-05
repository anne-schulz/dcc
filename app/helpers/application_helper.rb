# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def project_display_value(project)
    "<span title='URL: #{project.url}; Branch: #{project.branch}'>#{project.name}</span>"
  end

  def build_display_value(build)
    value = "<span title='#{build.identifier} " +
        "verwaltet von #{build.leader_uri}'>#{build.identifier[0..7]}</span>"
    if gitweb_base_url = build.project.gitweb_base_url
      value = "<a href='#{gitweb_base_url}?p=#{build.project.git_project};a=commit;" +
          "h=#{build.commit}'>#{value}</a>"
    end
    value
  end

  def bucket_display_value(bucket)
    "<span title='#{"auf #{bucket.worker_uri}" if bucket.worker_uri}'>#{bucket.name}</span>"
  end

  def bucket_display_status(bucket)
    display_status(bucket.status)
  end

  def build_display_status(build)
    display_status(build_status(build))
  end

  def display_status(status)
    case status
    when 10
      'done'
    when 20
      'pending'
    when 30
      'in work'
    when 35
      'processing failed'
    when 40
      'failed'
    else
      "unknown status #{status}"
    end
  end

  def build_status(build)
    build.buckets.map {|b| b.status}.sort.last
  end

  def status_css_class(status)
    case status
    when 10
      'success'
    when 20
      'pending'
    when 30
      'processing'
    when 35
      'failure'
    when 40
      'failure'
    end
  end
end
