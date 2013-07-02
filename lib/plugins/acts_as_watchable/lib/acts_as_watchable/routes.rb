#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module OpenProject
  module Acts
    module Watchable
      module Routes
        mattr_accessor :models

        def self.matches?(request)
          params = request.path_parameters

          watched?(params[:object_type]) &&
          /\d+/.match(params[:object_id])
        end

        def self.add_watched(watched, options = nil)
          objects_base_klass = get_objects_base_class watched

          self.models ||= { }

          self.models[objects_base_klass.to_s] = options || watched.to_s.underscore.pluralize

          @watchregexp = Regexp.new(self.models.values.join("|"))
        end

        private

        def self.watched?(object)
          objects_base_klass = get_objects_base_class object
          matcher = self.models[objects_base_klass.to_s]

          @watchregexp.present? && @watchregexp.match(matcher).present?
        end

        def self.get_objects_base_class(object)
          klass = (object.is_a? Class) ? object : object.classify.constantize
          ancestor = klass.lookup_ancestors.last

          (ancestor == ActiveRecord::Base) ? klass : ancestor
        end
      end
    end
  end
end
