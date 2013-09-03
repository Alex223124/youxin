class SchedulerSerializer < ActiveModel::Serializer
  attributes :delayed_at,
             :ran_at
end