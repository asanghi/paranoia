module Paranoia
  def self.included(klazz)
    klazz.extend Query
  end

  module Query
    def paranoid? ; true ; end

    def find_only_deleted
      unscoped.only_deleted
    end
  end

  def destroy
    _run_destroy_callbacks
    self.update_attribute(:deleted_at, Time.now) if !deleted? && persisted?
    freeze
  end
  alias :delete :destroy

  def destroyed?
    !self[:deleted_at].nil?
  end
  alias :deleted? :destroyed?
end

class ActiveRecord::Base
  def self.acts_as_paranoid
    self.send(:include, Paranoia)
    default_scope :conditions => { :deleted_at => nil }
    scope :only_deleted, :conditions => ['deleted_at is not null']
  end

  def self.paranoid? ; false ; end
  def paranoid? ; self.class.paranoid? ; end
end
