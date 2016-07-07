# When you call MakeMakefile methods, they write information to ./mkmf.conf.
# Please don’t do that, MakeMakefile.
module MakeMakefile::Logging
  @logfile = File::NULL
end

# The Aws gem complains on STDOUT when you’re redirected to the right region.
# Silence warnings about region redirects, they’re unavoidable with this tool.
module Aws
  module Plugins
    class S3RequestSigner < Seahorse::Client::Plugin
      class BucketRegionErrorHandler < Handler
        def log_warning(*args)
          # Intentional no-op
        end
      end
    end
  end
end
