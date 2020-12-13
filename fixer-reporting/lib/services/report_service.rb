class ReportService
  THRESHOLDS = [1.day, 7.days, 1.month, 1.year] 

  def call
    today_rate = fixer_service_call

    diffs = THRESHOLDS.map do |offset|
      rate = fixer_service_call(offset: offset)
      next if rate.blank?

      today_rate - rate
    end

    row = [today_rate] + diffs

    puts row

    save_file(row.join(";"))
  end

  private

  def fixer_service_call(offset: 0)
    date = Date.current - offset
    FixerService.new(date).call
  end

  def save_file(data)
    file = Tempfile.new("#{Date.current}.csv")
    file.write data
    file.close
  end
end