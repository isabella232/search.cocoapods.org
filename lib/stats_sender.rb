require 'rest'

class StatsSender
  URL = ENV['STATUSPAGE_URL']
  API_KEY = ENV['STATUSPAGE_API_KEY']

  def self.cleanup
    init
    $stdout.puts "Stat PIDs: #{@current_pids}"
    if pid = @current_pids.shift
      Process.waitpid(pid, Process::WNOHANG)
    end
  end

  def self.send(time, count)
    cleanup

    data = {
      data: {
        timestamp: time.to_i,
        value: count,
      },
    }
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "OAuth #{API_KEY}",
    }
    if URL
      @current_pids << fork do
        begin
          REST.post(URL, data.to_json, headers) do |http|
            http.open_timeout = 5
            http.read_timeout = 5
          end
        rescue REST::Error => e
          $stderr.puts "[Warning] Timeout when sending stats with #{data}: #{e.message}."
        end
      end
    end
  rescue StandardError => e
    $stderr.puts "[Warning] #{e.inspect}: #{e.backtrace}"
  end

  def self.init
    @current_pids ||= []
  end
end
