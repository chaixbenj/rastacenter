include ChunkyPNG::Color
class RunscreenshotJob < ApplicationJob
  queue_as :low_priority
  def perform(domaine_id, run_id, screenshotuid, screenshotname, psuite_id, ptest_id, pproc_id, test_node_id_externe, stringconfig, screenshotdata, compare)
			  resultimage = RunScreenshot.new
			  resultimage.domaine_id = domaine_id
			  resultimage.guid = screenshotuid
			  resultimage.run_id = run_id
			  resultimage.name = screenshotname
			  suite_id = ""
			  test_id = ""
			  proc_id = ""
			  if psuite_id.to_s != ""
				suite = Sheet.where(:id => psuite_id).first
				if suite != nil then suite_id = suite.current_id.to_s end
			  end
			  if ptest_id.to_s != ""
				test = Test.where(:id => ptest_id).first
				if test != nil then test_id = test.current_id.to_s end
			  end
			  if pproc_id.to_s != ""
				proc = Procedure.where(:id => pproc_id).first
				if proc != nil then proc_id = proc.current_id.to_s end
			  end
			  location = suite_id + "_" + test_id + "_" + test_node_id_externe.to_s + "_" + proc_id
			  resultimage.location = location
			  resultimage.configstring = stringconfig
			  resultimage.pngname = "#{domaine_id}_#{screenshotuid}.png" #Base64.decode64(screenshotdata)
			  resultimage.type_screenshot = 'last'
			  tentative = 0
			  newfile = File.open("./public/screenshots/#{domaine_id}_#{screenshotuid}.png", "wb")
			  scaled_bytes = Base64.decode64(screenshotdata)
			  newfile.puts scaled_bytes
			  newfile.close
			  begin
			  saved = resultimage.save
			  rescue 
			  tentative += 1
			  end until (saved or tentative > 1000) 
			  if screenshotname != "run_step_error"
				  refimage = RefScreenshot.where(:name => screenshotname, :configstring => stringconfig, :location => location).first
				  if refimage == nil or (File.exists?("./public/screenshots/#{refimage.pngname}")==false)
					if refimage == nil then refimage = RefScreenshot.new end
					refimage.domaine_id = domaine_id
					refimage.name = resultimage.name
					refimage.configstring = resultimage.configstring
					refimage.location = resultimage.location
					refimage.pngname = "ref_#{domaine_id}_#{screenshotuid}.png" #resultimage.data64
					tentative = 0
					newfile = File.open("./public/screenshots/ref_#{domaine_id}_#{screenshotuid}.png", "wb")
					scaled_bytes = Base64.decode64(screenshotdata)
					newfile.puts scaled_bytes
					newfile.close
					begin
					  saved = refimage.save
					rescue
					  tentative += 1
					end until (saved or tentative > 1000) 
				  else
					if compare.to_s == "true"
					 refpng = File.open("./public/screenshots/#{refimage.pngname}", "rb").read
					 pourcentagechange, png_data = compare_image(Base64.decode64(screenshotdata), refpng)
						diffimage = resultimage.dup
						if pourcentagechange > 0.000 then diffimage.has_diff = 1 else diffimage.has_diff = 0 end
						diffimage.pngname = "diff_#{domaine_id}_#{screenshotuid}.png" #png_data
						diffimage.type_screenshot = 'diff'
						diffimage.prct_diff = (pourcentagechange * 100).to_i 
						tentative = 0
						newfile = File.open("./public/screenshots/diff_#{domaine_id}_#{screenshotuid}.png", "wb")
						scaled_bytes = png_data #Base64.decode64(screenshotdata)
						newfile.puts scaled_bytes
						newfile.close
						begin
							saved = diffimage.save
						rescue Exception => e
							tentative += 1
						end until (saved or tentative > 1000) 
						
						run_screenshot_diff = RunScreenshot.select("count(1) as nb").where(:domaine_id => domaine_id, :run_id => run_id, :type_screenshot => 'diff', :has_diff => 1).first
						if run_screenshot_diff != nil
							run = Run.where(:id => run_id).first
							if run != nil
								run.nb_screenshots_diffs = run_screenshot_diff.nb
								run.save
							end
						end
						
					end
				  end
			  end
  end
  
  
  def compare_image(b_imagelast, b_imageref)
	imagelast = ChunkyPNG::Image.from_blob(b_imagelast)
	imageref = ChunkyPNG::Image.from_blob(b_imageref)
	iw = 0
	ih = 0 
	
	if imageref.width >  imagelast.width
		iw = imagelast.width
		ih = imagelast.height
		coeff = imagelast.width.to_f / imageref.width.to_f 
		if imagelast.height > imageref.height * coeff then ih = (imageref.height * coeff).round end
		resized_image = ChunkyPNG::Image.new(iw, ih)
		resized_image.pixels.map!.with_index do |pixel, index|
			x, y = index % resized_image.width, (index / resized_image.width).floor
			imageref[x / coeff, y / coeff]
		end
		imageref = resized_image
	else
		iw = imageref.width
		ih = imageref.height
		coeff = imageref.width.to_f / imagelast.width.to_f 
		if imageref.height > imagelast.height * coeff then ih = (imagelast.height * coeff).round end
		resized_image = ChunkyPNG::Image.new(iw, ih)
		resized_image.pixels.map!.with_index do |pixel, index|
			x, y = index % resized_image.width, (index / resized_image.width).floor
			imagelast[x / coeff, y / coeff]
		end
		imagelast = resized_image	
	end
	
	images = [
	  imageref,
	  imagelast
	]
	#output = ChunkyPNG::Image.new(iw, ih, :white)
	output = imageref
	diff = []

	ih.times do |y|
	  images.first.row(y).each_with_index do |pixel, x|
		unless pixel == images.last[x,y]
		  score = Math.sqrt(
			(r(images.last[x,y]) - r(pixel)) ** 2 +
			(g(images.last[x,y]) - g(pixel)) ** 2 +
			(b(images.last[x,y]) - b(pixel)) ** 2
		  ) / Math.sqrt(MAX ** 2 * 3)

		  #output[x,y] = grayscale(MAX - (score * MAX).round)
		  output[x,y] = rgb(255, 0, 0)
		  diff << score
		end
	  end
	end

	pourcentagechange = (diff.length.to_f / images.first.pixels.length.to_f) * 100.000
	png_data =  output.to_blob
	
	return pourcentagechange, png_data
end

end