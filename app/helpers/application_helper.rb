module ApplicationHelper
  def javascript_wattle
     "<script>watCatcher.appEnv= \"#{Rails.env}\";</script>".html_safe
  end

  def checked? param, key
    params[param].present? && params[param].include?(key)
  end
end
