# encoding: utf-8

module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def time_ago_in_words(time)
    distance = (Time.now - time).to_i
    # seconds ago
    if distance/60 < 1
      return "#{distance}秒前"
    end

    # minutes ago
    distance = (distance/60).to_i
    if distance/60 < 1
      return "#{distance}分前"
    end

    # hours ago
    distance = (distance/60).to_i
    if distance/24 < 1
      return "#{distance}小时前"
    end

    # days ago
    distance = (distance/24).to_i
    if distance/3 < 1
      return "#{distance}天前"
    end

    time.strftime("%m月%d日%H:%M")
  end

  def file_size_in_words(size)
    size = size.to_i
    if size/1000 < 1
      return "#{size}B"
    end

    size = size/1000
    if size/1024 < 1
      return "#{size}KB"
    end

    size = size/1024
    if size/1024 < 1
      return "#{size}MB"
    end

    size = size/1024
    return "#{size}GB"
  end
end
