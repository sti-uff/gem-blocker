class NonComplianceProjects

  def list
    projects = []
    Project.all.each do |project|
      project_with_gems = {}
      used_gems = last_used_gems_of project
      next if used_gems.nil?
      project_with_gems["#{project.name}"] = []
      required_gems = verify_locked_gems(used_gems, :required)
      project_with_gems["#{project.name}"] << required_gems
      projects << project_with_gems unless project_with_gems["#{project.name}"].empty?
    end
    projects
  end

  def last_used_gems_of project
    used_gems = []
    hash = {}
    return if project.commits.empty?
    gems = project.commits.last.used_gems
    gems.each do |gem|
      hash["#{gem.name}"] = gem.version
      used_gems << hash
    end
    hash
  end

  def verify_locked_gems(used_gems, type)
    locked_gems = { type => { } }
    required_gems = Gemblocker.hash_of type.to_s.titleize
    required_gems.each do |required_gem|
      gem_name = required_gem.keys.first
      if used_gems[gem_name] && type != :deny
        unless required_gem[gem_name].include? used_gems[gem_name]
          locked_gems[type]["#{gem_name}"] = used_gems[gem_name]
        end
      else
        if required_gem[gem_name].include? used_gems[gem_name]
          locked_gems[type]["#{gem_name}"] = used_gems[gem_name]
        end
      end
    end
    locked_gems if locked_gems[type].any?
  end


end