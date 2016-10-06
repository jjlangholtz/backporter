class Label
  attr_reader :name, :branch, :conflict, :success

  def self.target_label_names
    @target_label_names ||= []
  end

  def self.label_store
    @label_store ||= YAML.load_file(Rails.root.join('config/labels.yml'))
  end

  def self.load
    label_store.each { |name| target_label_names << name.to_s }
  end

  def self.for(name)
    label = label_store[name.to_sym]
    new(name, label[:branch], label[:conflict], label[:success])
  end

  def initialize(name, branch, conflict, success)
    @name = name
    @branch = branch
    @conflict = conflict
    @success = success
  end
end
