class ChartToImg
	attr_accessor :image_files
	def initialize
		@chart_legend = "&chdl="
  	@chart_data = "&chd=t:"
  	@url = "https://chart.googleapis.com/chart?cht=p&chs=450x200&chds=a&chco=FF0000"
  	@image_files = ""
  end

  def save_to_image(chart_data)
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
    
    @url = @url + @chart_legend.chomp('|') + @chart_data.chomp(',')
    path_image = "#{Rails.root}/app/assets/images/chart-#{@url.hash}.png"
    open @url do |chart|
      File.open(path_image, 'wb') {|f| f.write chart.read}
    end
    @image_files = "chart-#{@url.hash}.png"
  end
end