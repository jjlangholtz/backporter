module Settings
  class << self
    def load
      @data = YAML.load_file(Rails.root.join('config/settings.yml'))
    end

    def backport_label
      @data.dig(:project, :backport_label)
    end

    def repo
      @data.dig(:project, :repo)
    end

    def target_branch
      @data.dig(:project, :target_branch)
    end

    def target_label
      @data.dig(:project, :target_label)
    end
  end
end

Settings.load
