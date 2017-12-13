class ChartToImg
	attr_accessor :image_files
	def initialize
		@chart_legend = "&chdl="
  	@chart_data = "&chd=t:"
    @url = "https://chart.googleapis.com/chart?cht=p&chs=450x200&chds=a&chco=399977,D9CC3C,E5A51B,F27B29,E8574C"
  	# @url = "https://chart.googleapis.com/chart?cht=p&chs=450x200&chds=a&chco=468966,FFF0A5,FFB03B,B64926,8E2800"
  	@image_files = ""
  end

  def save_to_image(chart_data, title)
  	chart_data.each_with_index do |data, idx|
      case idx
      when 0
      else
        unless data[1] == 0
          @chart_legend << "#{data[0]} - $#{data[1]}|" 
          @chart_data << "#{data[1]},"
        end
      end
    end
    
    @url = @url + @chart_legend.chomp('|') + @chart_data.chomp(',') + "&chtt=#{title}"
    path_image = "#{Rails.root}/app/assets/images/chart-#{@url.hash}.png"
    open @url do |chart|
      File.open(path_image, 'wb') {|f| f.write chart.read}
    end
    @image_files = "chart-#{@url.hash}.png"
  end
end