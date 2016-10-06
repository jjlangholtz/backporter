class Label
  attr_reader :name, :branch, :conflict, :success

  def self.target_label_names
    label_store.keys.map(&:to_s)
  end

  def self.label_store
    @label_store ||= YAML.load_file(Rails.root.join('config/labels.yml'))
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
