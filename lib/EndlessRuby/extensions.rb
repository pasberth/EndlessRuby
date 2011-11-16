require 'rubygems'
module Kernel
  alias endlessruby_original_require require
  def require path
    at = caller
    endlessruby_original_require path
  rescue Exception
    case path
    when /^\.\/.*?$/, /^\/.*?$/
      unless File.exist? path
        $@ = at
        raise LoadError, "no such file to load -- #{path}"
      end
      if File.directory? path
        $@ = at
        raise LoadError, "Is a directory - #{path}"
      end
      open(path) do |file|
        begin
          TOPLEVEL_BINDING.eval EndlessRuby.to_pure_ruby(file.read), File.expand_path(path)
        rescue Exception => e
          $@ = at
          raise e
        end
        return true
      end
    else
      is_that_dir = false
      $LOAD_PATH.each do |load_path|
        real_path = File.join load_path, path
        next unless File.exist? real_path
        next is_that_dir = true if File.directory? real_path
        open(real_path) do |file|
          begin
            TOPLEVEL_BINDING.eval EndlessRuby.to_pure_ruby(file.read), File.expand_path(real_path)
          rescue Exception => e
            $@ = at
            raise e
          end
        end
        return true
      end
      $@ = at
      if is_that_dir
        raise LoadError, "Is a directory - #{path}"
      else
        raise LoadError, "no such file to load -- #{path}"
      end
    end
  end
end