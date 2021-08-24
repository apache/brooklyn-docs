#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

# tag to read and insert a file relative to the current working directory
# (like include, but in the dir where it is invoked)

# there is also readj which reads a file and applies jekyll processing to it
# handy if we want to include a toc.json file which itself calls {% read_jekyll child/toc.json %}
# (note however variables do not seem to be exported when use readj (TODO),
# although they are exported if you have _includes/file.md and use the standard include file)

# the argument can be a variable or a filename literal (not quoted)
# TODO: figure out how to accept a quoted string as an argument

require 'pathname'

module JekyllRead
  class ReadTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
      @mode = :auto
    end

    def load_file(context, filename, context_page)
      # Pathname API ignores first arg below if second is absolute
      file = Pathname.new(File.dirname(context_page['path'])) + filename
      file = file.cleanpath

      # is there a better way to trim a leading / ?
      file = file.relative_path_from(Pathname.new("/")) unless file.relative?
      raise "No such file #{file} in read call" unless file.exist?
      file
    end

    def render_jekyll(context, filename)
      file = load_file(context, filename, context['page'] || context.registers[:page])

      # support vars and paths relative to a file being readj'd
      jekyllSite = context.registers[:site]
      targetPage = Jekyll::Page.new(jekyllSite, jekyllSite.source, File.dirname(file), File.basename(file))
      targetPage.render(jekyllSite.layouts, jekyllSite.site_payload)
      targetPage.output
    end

    def render_literal(context, filename)
      file = load_file(context, filename, context['page'])

      file = File.open(file, "rb")
      return file.read
    end

    def render(context)
      filename = @text.strip
      context[filename] || filename

      mode = @mode
      if (mode == :auto)
        mode = filename.end_with?(".md") ? :jekyll : :literal
      end
      if (mode == :jekyll)
        render_jekyll(context, filename)
      elsif (mode == :literal)
        render_literal(context, filename)
      else
        raise "Unknown mode #{mode}"
      end

    end
  end

  class ReadJekyllTag < ReadTag
    def initialize(tag_name, text, tokens)
      super
      @mode = :jekyll
    end
  end
  class ReadLiteralTag < ReadTag
    def initialize(tag_name, text, tokens)
      super
      @mode = :literal
    end
  end
end

Liquid::Template.register_tag('read', JekyllRead::ReadTag)
Liquid::Template.register_tag('read_jekyll', JekyllRead::ReadJekyllTag)
Liquid::Template.register_tag('read_literal', JekyllRead::ReadLiteralTag)

# for compatibility with old markdown
Liquid::Template.register_tag('readj', JekyllRead::ReadJekyllTag)
