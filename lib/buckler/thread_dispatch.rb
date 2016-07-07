module Buckler
  class ThreadDispatch

    include Buckler::Logging

    def initialize
      @lambda_pool = []
      @thread_pool = []
      @max_threads = Etc.nprocessors * 2 # Twice the number of CPU cores available to Ruby
    end

    def queue(λ)
      @lambda_pool << λ
    end

    def any_running_threads?
      @thread_pool.any?{|s| s.status == "run"}
    end

    def running_thread_count
      @thread_pool.select{|s| s.status == "run"}.count
    end

    def perform_and_wait

      Thread.abort_on_exception = true

      start_time = Time.now

      @lambda_pool.each do |λ|
        while running_thread_count >= @max_threads
          verbose "Sleeping due to worker limit. #{running_thread_count} currently running."
          sleep 0.2
        end
        @thread_pool << Thread.new(&λ)
      end

      verbose "All workers spawned, waiting for workers to finish"
      while any_running_threads? do
        sleep 0.2
      end

      return (Time.now - start_time).round(2)

    end

  end
end
