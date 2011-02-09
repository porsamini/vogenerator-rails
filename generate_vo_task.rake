VO_SUFFIX = '.as'

desc "Generates the VO files for the project models.
    Note: Pass the model names as params, 
    for ex: 'rake create_vo_files MODEL_NAMES=address,city,customer_phone'"
    task :create_vo_files do
      EXCLUDE_MODELS = []
      #require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
      require "config/environment"
      require File.join(File.dirname(__FILE__), "vo_file_creation.rb")
      
      if ENV['SKIP_MODELS']
       EXCLUDE_MODELS = ENV['SKIP_MODELS'].split(',').collect do |x|
         x.camelize
       end
      end
      if ENV['MODEL_NAMES']
        class_names = ENV['MODEL_NAMES'].split(',').collect do |x|
          x.camelize      
        end
      else
        class_names = VoFileCreation.get_model_names.collect do |x|
          x.chomp(".rb").camelize
        end
      end
        
      class_names.each do |class_name|
        #FileUtils.mkpath("flexapp/BankingSystemVO") unless File.directory?('flexapp/BankingSystemVO')
        #if class_name.constantize.methods.include?("table_name") && !class_name.constantize.abstract_class && !EXCLUDE_MODELS.include?(class_name)
          begin
        if class_name.constantize.methods.include?('table_exists?') && class_name.constantize.table_exists? && !EXCLUDE_MODELS.include?(class_name)
          new_vo_file = File.new("flexapp/BankingSystemVO/src/com/bankingsystem/valueobjects/#{class_name+'VO'+VO_SUFFIX}", "w+")
          puts "Creating VO file for #{class_name}."
          VoFileCreation.write_into_vo_file(new_vo_file,class_name.constantize)
        else
          puts "Skipped VO file for #{class_name}."          
        end
          rescue
        print "'#{class_name.downcase}' is not in model directory or the table for '#{class_name.downcase}' does not exist in the database.\n 1. You either didn't spell the name right. Or \n 2. Your database migration is not updated. Or \n 3. There may be an undefined method in the model '#{class_name.downcase}'"
          next
          end
      end
   end