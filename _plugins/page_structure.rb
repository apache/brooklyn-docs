#
# Adds a liquid tag to build a page on the contents of the folder it's in
# 
# Pulls in files in the format <Number>_<title>.md in the order of version number. Ignores files not in this format.
#

require 'rubygems'
require 'yaml'
require "kramdown"

module PageStructureUtils
  
  class ChildPage
    def initialize(yaml, content)
      @yaml=yaml
      @content=content
    end
    attr_accessor :yaml
    attr_accessor :content
    def to_s # called with print / puts
      "YAML : #{@yaml}" #, Content : #{@content}"
    end

    ##
    # Sort a list of children by their YAML containing section positions. Do this with Gem:Version
    #
    #
    def self.sortBySectionPositions(yaml)
      
      $major = "1"
      $minor = 1
      # first check all the child pages are numbered, if not, number them in the order they are
      yaml.each do |i|
        if i.yaml['section_position'] == nil
          i.yaml['section_position'] = $major+"."+$minor.to_s
          $minor += 1
        else
          # Store any major, start incrementing minor
          $major = i.yaml['section_position'].to_s
          $minor = 1
        end
      end
      
      # return the comparison between the versions
      yaml.sort{ |x,y| Gem::Version.new(x.yaml['section_position'].to_s) <=> Gem::Version.new(y.yaml['section_position'].to_s) }
    end
    ##
    # Sorts a list of yaml children, if there's no numbering, use the YAML order to create a numbering
    #
    def self.sortYAMLSectionPositions(yaml)
#      puts "a > "+yaml.to_s
      hashArray = []
      $major = "1"
      $minor = 1
      # first check all the child pages are numbered, if not, number them in the order they are
      yaml.each do |i|
        hash = {}
        # if it's a string, convert it to a hash
        if i.instance_of? String
          hash = { "path" => i }
        else
          hash = i
        end
        if i['section_position'] == nil
          hash['section_position'] = $major+"."+$minor.to_s
          $minor += 1
        else
          # Store any major, start incrementing minor
          $major = i['section_position'].to_s
          $minor = 1
        end
        hashArray << hash
      end
      # return the comparison between the versions (NB: sort! for in-place sorting)
      hashArray.sort!{ |x,y| Gem::Version.new(x['section_position'].to_s) <=> Gem::Version.new(y['section_position'].to_s) }
#      puts "2 > "+hashArray.to_s
    end
    
    ##
    # This function looks at all the *.md files at the YAML in the headers and produces a list of children ordered by section_position
    #
    #
    def self.parseChildYAMLFromParent(page)
      # get the base directory of the current file
      $baseFile = Dir.pwd+page['dir']
      # list all of the files in that directory
      $listings = Dir[$baseFile+"/*.md"]
      $allPages = []

      for $listing in $listings
                
        # read the file
        $fileContent = IO.read($listing)
        # try and split of any YAML
        $partitionedFileContent = $fileContent.split('---');
        # if there's potentially partitioned YAML try and parse it
        if $partitionedFileContent.size > 2
          # try and parse the YAML
          yamlContent = YAML.load($partitionedFileContent[1])
          # if we can, use it (section_type needs to be one of the allowed)
          if yamlContent != nil && yamlContent != false && yamlContent['section_type'] != nil && yamlContent['section_type'] != "default"

            if yamlContent['section_type'] == nil
              # if no section position has been specified, put it at the end
              yamlContent['section_position'] = Integer::MAX
            end
            # if there's YAML, check it has the section_position tag and put it into child pages
            ($allPages ||= []) << ChildPage.new(yamlContent, $partitionedFileContent[2])
          end
        end     
      end
      $allPages = sortBySectionPositions($allPages)
      # return the combined content
      $allPages
    end
          
    ##
    # This function looks in a parent folder for all files in the format <Number>_<title>.md
    # 
    #
    def self.parseChildPagesFromParent(page)
      # get the base directory of the current file
      $baseFile = Dir.pwd+page['dir']
      # list all of the files in that directory
      $listings = Dir[$baseFile+"/*"]
      # filter by the key pattern
      $listings = $listings.select{ |i| i[/[\d\.]\_.*\.md/] }
      # Sort the files based on the Gem::Version of the prefix
      $listings = $listings.sort{ |x,y| Gem::Version.new((File.basename x).partition('_').first) <=> Gem::Version.new((File.basename y).partition('_').first)  }
      # loop through them and merge the content
      $allPages = []

      for $listing in $listings
        $textContent = ""
        yamlContent = nil
                
        # read the file
        $fileContent = IO.read($listing)
        # try and split of any YAML
        $partitionedFileContent = $fileContent.split('---');
        # if there's potentially partitioned YAML try and parse it
        if $partitionedFileContent.size > 2
          # try and parse the YAML
          yamlContent = YAML.load($partitionedFileContent[1])
          # if we can, use it
          if yamlContent != nil && yamlContent != false
            $textContent = $partitionedFileContent[2]
          end
        end
        
        # if there's no text content set yet, just use the whole file
        if $textContent == ""
          # use the whole file content
          $textContent = $fileContent
        end
        # append the current file to the content
        ($allPages ||= []) << ChildPage.new(yamlContent, $textContent)
                
      end
      # return the combined content
      $allPages
    end
  end
  
  class IncludePageContentTag < Liquid::Tag
      def initialize(tag_name, text, tokens)
        super
        @text = text.strip
      end
      def render(context)
#        $childPages = ChildPage.parseChildPagesFromParent(context['page'])
        $childPages = ChildPage.parseChildYAMLFromParent(context['page'])
        $content = ""
        for $childPage in $childPages
          #append the content
          $content = $content+$childPage.content()
        end
        site = context.registers[:site]
        pageHash = context.registers[:page]
          
        # not sure how to get the page object so look through site.pages for the current URL
        page = nil;
        for currPage in site.pages
          if currPage['url'] == pageHash['url']
            page = currPage
            break
          end
        end

        # render the included content with the current page renderer
        info = { :filters => [Jekyll::Filters], :registers => { :site => site, :page => page } }
        page.render_liquid($content, site.site_payload, info)
      end
    end
end

Liquid::Template.register_tag('child_content', PageStructureUtils::IncludePageContentTag)