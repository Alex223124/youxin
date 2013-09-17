# encoding: utf-8

require 'spec_helper'

describe ApplicationHelper do

  describe 'time_ago_in_words' do
    it 'should return in seconds' do
      time = 10.seconds.ago
      time_ago_in_words(time).should == "10秒前"
    end
    it 'should return in minutes' do
      time = 10.minutes.ago
      time_ago_in_words(time).should == "10分前"
    end
    it 'should return in hours' do
      time = 10.hours.ago
      time_ago_in_words(time).should == "10小时前"
    end
    it 'should return in days' do
      time = 24.hours.ago
      time_ago_in_words(time).should == "1天前"
    end
    it 'should return in days' do
      time = 34.hours.ago
      time_ago_in_words(time).should == "1天前"
    end
    it 'should return in days' do
      time = 48.hours.ago
      time_ago_in_words(time).should == "2天前"
    end
    it 'should return in days more than 3 days' do
      time = 4.days.ago
      time_ago_in_words(time).should == time.strftime("%m月%d日%H:%M")
    end
  end

  describe 'file_size_in_words' do
    it 'should return in B' do
      size = 10
      file_size_in_words(size).should == "#{size}B"
    end
    it 'should return in KB' do
      size = 1000
      file_size_in_words(size).should == "1KB"
    end
    it 'should return in MB' do
      size = 1000 * 1024
      file_size_in_words(size).should == "1MB"
    end
    it 'should return in GB' do
      size = 1000 * 1024 * 1024
      file_size_in_words(size).should == "1GB"
    end
    it 'should return in GB' do
      size = 1000 * 1024 * 1024 * 123
      file_size_in_words(size).should == "123GB"
    end
    it 'should return in B when string' do
      size = '10'
      file_size_in_words(size).should == "10B"
    end
  end
end
