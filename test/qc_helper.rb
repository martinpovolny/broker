class QC::TestWorker < QC::Worker
    def handle_failure(job, e)
        #FailedQueue.enqueue(job)
        raise e
    end

    def go!
      loop do
        job = @queue.lock(@top_bound)
        break if job.nil?
        process(job)
      end
    end
end

class QC::TestHelper
  def self.go!
    worker = QC::TestWorker.new(
      :fork_worker => false,
      #max_attempts: 10, listening_worker: true
    )
    worker.go!
  end
end
