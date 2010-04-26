require 'fileutils'
require 'wx'

class BackburnerSubmitter < Wx::App

  def on_init
    frame = BackburnerFrame.new
    frame.show
  end

end


class BackburnerFrame < Wx::Frame

  def initialize
    super nil,
      :title => 'Backburner Submitter',
      :style => (Wx::SYSTEM_MENU|Wx::CAPTION|Wx::CLOSE_BOX|Wx::CLIP_CHILDREN),
      :size => Wx::Size.new(330,200)
    set_drop_target AepDropTarget.new self
    @panel = BackburnerPanel.new(self)
  end

  def dropped(files)
    @panel.dropped files
  end

end


class AepDropTarget < Wx::FileDropTarget

  def initialize(parent)
    super()
    @parent = parent
  end

  def on_drop_files(x, y, files)
    @parent.dropped files
    return true
  end

end


class BackburnerPanel < Wx::Panel

  def initialize(parent)
    super parent

    @label = Wx::StaticText.new self,
      :label => "\n\n\n\nDrop After Effects\nfile here\n\nNOTE: ensure file is\naccessible on all machines",
      :size => Wx::Size.new(200,200),
      :pos =>  Wx::Point.new(0,0),
      :style => (Wx::ALIGN_CENTRE|Wx::ST_NO_AUTORESIZE)

    Wx::StaticText.new self,
      :label => 'Comp Name',
      :size => Wx::Size.new(100,20),
      :pos => Wx::Point.new(200,10),
      :style => (Wx::ALIGN_LEFT|Wx::ST_NO_AUTORESIZE)

    @comp_entry = Wx::TextCtrl.new self,
      :size => Wx::Size.new(100,20),
      :pos => Wx::Point.new(200,30),
      :value => 'comp name'

    Wx::StaticText.new self,
      :label => 'Tasks',
      :size => Wx::Size.new(100,20),
      :pos => Wx::Point.new(200,60),
      :style => (Wx::ALIGN_LEFT|Wx::ST_NO_AUTORESIZE)

    @tasks_entry = Wx::TextCtrl.new self,
      :size => Wx::Size.new(100,20),
      :pos => Wx::Point.new(200,80),
      :value => '1'

    @button = Wx::Button.new self,
      :size => Wx::Size.new(100,50),
      :pos => Wx::Point.new(200,110),
      :label => 'Submit'

    @button.set_default
    evt_button(@button) { submit_job }
  end

  def dropped(files)
    files.each do |file|
      @file = file if File.extname(file) == '.aep'
    end
    @label.set_label("\n\n\n\n\nPress Submit to start:\n#{file_name}")
  end

  def file_name
    File.basename(@file, '.aep')
  end

  def output_dir
    File.join(File.dirname(@file), "#{file_name} render")
  end

  def submit_job
    FileUtils.mkdir output_dir unless File.directory? output_dir

    Kernel.system("cmdjob -jobname \"#{file_name}\" -jobnameAdjust -numTasks #{@tasks_entry.get_value} \"C:\\Program Files (x86)\\Adobe\\Adobe After Effects CS4\\Support Files\\aerender.exe\" -project \"#{@file}\" -mp -comp \"#{@comp_entry.get_value}\" -RStemplate \"Multi-Machine Settings\" -OMtemplate \"Multi-Machine PNG Sequence\" -output \"#{output_dir}/#{file_name} [####].png\"")
  end

end

BackburnerSubmitter.new.main_loop
