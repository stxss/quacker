class MutedWordsCleanupJob
  include Sidekiq::Job

  def perform(word_id)
    word = MutedWord.find_by(id: word_id)

    if word&.expiration
      MutedWord.find(word_id).delete
    else
      queue = Sidekiq::Queue.new("default")
      queue.each { |job| job.delete if job.jid == self.jid }
    end
  end
end
