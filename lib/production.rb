require 'production/version'
require 'database_cleaner'

class Production

  module ClassMethods
    def const_missing(name)
      namespace = self.name.split('::').tap(&:shift).join('::') # remove 'Production' from requested class namespace
      "#{namespace}::#{name}".constantize rescue nil # fire autoload
      if "#{namespace}".constantize.const_defined?(name)
        case "#{namespace}::#{name}".constantize.class.to_s
        when 'Module'
          return Module.new.tap do |m|
            m.extend(ClassMethods)
            const_set(name, m)
          end
        when 'Class'
          klass = Class.new("#{namespace}::#{name}".constantize)
          klass.establish_connection(connection)
          return klass
        end
      end
      super
    end
  end

  self.extend(ClassMethods)

  def self.connection
    @connection || :production
  end

  def self.connection=(conn)
    @connection = conn
  end

  def self.wrap(klass)
    Class.new(klass).tap { |c| c.establish_connection(connection) }
  end

  def self.push_from_development(*classes)
    classes.flatten.each do |klass|
      prod_klass = wrap(klass)
      cleaner    = DatabaseCleaner::Base.new(:active_record, connection: prod_klass)
      cleaner.clean_with(:truncation, only: [ prod_klass.table_name ])
      prod_klass.transaction do
        klass.find_each do |i|
          prod_klass.new.tap do |j|
            j.assign_attributes(i.attributes, without_protection: true)
          end.save!
        end
      end
    end
  end

  def self.pull_to_development(*classes)
    classes.flatten.each do |klass|
      prod_klass = wrap(klass)
      cleaner    = DatabaseCleaner::Base.new(:active_record, connection: klass)
      cleaner.clean_with(:truncation, only: [ klass.table_name ])
      klass.transaction do
        prod_klass.find_each do |i|
          klass.new.tap do |j|
            j.assign_attributes(i.attributes, without_protection: true)
          end.save!
        end
      end
    end
  end

end
