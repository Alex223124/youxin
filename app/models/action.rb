# encoding: utf-8

class Action
  class << self
    def options
      {}.
        merge(organization).
        merge(user).
        merge(youxin)
    end
    def options_array
      options.collect { |k, v| k }
    end

    def options_for(item)
      return {} unless %w(organization user youxin).include?(item.to_s)
      self.send(item)
    end
    def options_array_for(item)
      options_for(item).collect { |k, v| k }
    end

    def to_human(option)
      options[option]
    end

    def organization
      {
        create_organization: '新建组织',
        delete_organization: '删除组织',
        edit_organization: '编辑组织',
      }
    end
    def user
      {
        add_member: '添加成员',
        remove_member: '移除成员',
        edit_member: '编辑成员信息'
      }
    end
    def youxin
      {
        create_youxin: '发送优信',
        create_sms: '发送短信'
      }
    end
  end
end