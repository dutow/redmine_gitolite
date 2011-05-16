module Gitolite
  class Config
		def initialize file_path
			@path = file_path
			load
		end

		def save
			File.open(@path, "w") do |f|
				f.puts content
			end
			@original_content = content
		end

		def add_write_user repo_name, users
			repository(repo_name).add "RW+", users
		end

		def set_write_user repo_name, users
			repository(repo_name).set "RW+", users
		end

		def add_read_user repo_name, users
			repository(repo_name).add "R", users
		end

		def set_read_user repo_name, users
			repository(repo_name).set "R", users
		end

		def changed?
			@original_content != content
		end

		private
		def load
			@original_content = []	
			@repositories = {}
			cur_repo_name = nil
			File.open(@path).each_line do |line|
				@original_content << line
				tokens = line.strip.split
				if tokens.first == 'repo'
					cur_repo_name = tokens.last
					@repositories[cur_repo_name] = AccessRights.new
					next
				end
				cur_repo_right = @repositories[cur_repo_name]
				if cur_repo_right and tokens[1] == '='
					cur_repo_right.add tokens.first, tokens[2..-1]
				end
			end
			@original_content = @original_content.join
		end

		def repository repo_name
			@repositories[repo_name] ||= AccessRights.new
		end


		def content
			content = []
			@repositories.each do |repo, rights|
				content << "repo\t#{repo}"
				rights.each do |perm, users|
					content << "\t#{perm}\t=\t#{users.join(' ')}" if users.length > 0
				end
				content << ""
			end
			return content.join("\n")
		end

	end

	class AccessRights
		def initialize
			@rights = {}
		end

		def add perm, users
			@rights[perm.to_sym] ||= []
			@rights[perm.to_sym] << users
			@rights[perm.to_sym].flatten!
			@rights[perm.to_sym].uniq!
		end

		def set perm, users
			@rights[perm.to_sym] = []
			add perm, users
		end

		def each 
			@rights.each {|k,v| yield k, v}
		end
	end
end

