# Generate markdown file for each entry in the provided bib file in _config.yml

require 'bibtex'

def swapauth(x)
  xs = x.split(/\s*,\s*/)
  if xs.length == 2
    return xs[1] + ' ' + xs[0]
  else
    return x
  end
end


def replaceAccents(s)
    """
    Replaces LaTeX symbols with extended ASCII equivalents.
    (It avoids using Unicode because that doesn't render well.)
    """

    s = s.gsub("{\\`a}",  'à')
    s = s.gsub("{\\'a}",  'á')
    s = s.gsub("{\\´a}",  'á')
    s = s.gsub("{\\^a}",  'â')
    s = s.gsub("{\\~a}",  'ã')
    s = s.gsub("{\\\"a}", 'ä')
    s = s.gsub("{\\r a}", 'å')

    s = s.gsub("{\\`e}",  'è')
    s = s.gsub("{\\'e}",  'é')
    s = s.gsub("{\\^e}",  'ê')
    s = s.gsub("{\\\"e}", 'ë')

    s = s.gsub("{\\`i}",  'ì')
    s = s.gsub("{\\'i}",  'í')
    s = s.gsub("{\\^i}",  'î')
    s = s.gsub("{\\\"i}", 'ï')

    s = s.gsub("{\\`o}",  'ò')
    s = s.gsub("{\\'o}",  'ó')
    s = s.gsub("{\\^o}",  'ô')
    s = s.gsub("{\\\"o}", 'ö')
    s = s.gsub("{\\~o}",  'õ')
    s = s.gsub("{\\u o}", 'ð')

    s = s.gsub("{\\\"O}", 'Ö')

    s = s.gsub("{\\`u}",  'ù')
    s = s.gsub("{\\'u}",  'ú')
    s = s.gsub("{\\^u}",  'û')
    s = s.gsub("{\\\"u}", 'ü')

    s = s.gsub("\\c{t}",  'ţ')
    s = s.gsub("{\\ct}",  'ţ')
    s = s.gsub("{\\c t}", 'ţ')

    s = s.gsub("\\v{a}",  'ă')
    s = s.gsub("{\\va}",  'ă')
    s = s.gsub("{\\v a}", 'ă')

    s = s.gsub("{\\v C}a",'Că')
    s = s.gsub("{\\v c}",  'č')
    s = s.gsub("{\\' c}",  'ć')
    s = s.gsub("\\c c",   'ç')

    s = s.gsub("\\~n",    'ñ')
    s = s.gsub("\\o",     'ø')
    s = s.gsub("{\\'y}",  'ý')
    s = s.gsub("{\\\"y}", 'ÿ')

    # s = s.gsub("{\\l}",   u"ł")

    s = s.gsub("--", '-')
    s = s.gsub("\\textendash ", '-')
    s = s.gsub("\\textemdash ", '-')
    # s = s.gsub("--", '–')
    # s = s.gsub("\\textendash ", '–')
    # s = s.gsub("\\textemdash ", '—')

    s = s.gsub('’', '\'')
    s = s.gsub("\\textquotesingle ",   '\'')
    s = s.gsub("\\textquoteleft ",     '\'')
    s = s.gsub("\\textquoteright ",    '\'')
    s = s.gsub("\\textquotedouble ",   '\"')
    s = s.gsub("\\textquotedblleft ",  '\"')
    s = s.gsub("\\textquotedblright ", '\"')
    # s = s.gsub("\\textquotedblleft ",  "“")
    # s = s.gsub("\\textquotedblright ", "”")
    # s = s.gsub("\\textquoteleft ",     '‘')
    # s = s.gsub("\\textquoteright ",    '’')

    s = s.gsub("\\textasciitilde ", "~")
    s = s.gsub("\\textasciigrave ", "`")
    s = s.gsub("\\&", "&")
    s = s.gsub("\\_", "_")
    s = s.gsub("{-}", "-")

    s = s.gsub("\n", " ")

    return s
end


require 'date'
require 'rexml/document'

def cleanup(e)
  # Cleanup data read from the BibTeX file
  e.transform_values!(&:strip)

  if e.has_key?('authors')
    e['author'] = e['authors']
  end

  if e.has_key?('author')
    # bib entries for proceedings don't have an author
    author = e['author']
    author = replaceAccents(author)

    authors = author.split(/\s+and\s+/)
    authors = authors.map(&:strip).map { |a| swapauth(a) }
    e['authors'] = authors
    e.delete('author')
  else
    puts "No author #{e['ID']}"
  end

  if e.has_key?('title')
    e['title'] = e['title'].gsub(/[{}]/, '')
  else
    puts "No title #{e['ID']}"
  end

  if e.has_key?('year')
    e['year'] = e['year'].to_i
  else
    puts "No year #{e['ID']}"
  end

  %w[abstract address booktitle day doi editor institution note number pages school series title url].each do |i|
    if e.has_key?(i)
      e[i] = replaceAccents(e[i])
    end
  end

  if e.has_key?('url')
    e['link'] = e['url']
  end

  e['layout'] = 'paper'
  e['read'] = false
  e['readings'] = []
  e['added'] = Date.today
  return e
end

def create_files_from_bib(project_root, bib_dir, bib_file)
  bib_file = File.join(project_root, bib_dir, bib_file)
  bib = BibTeX.open(bib_file)

  bib.each do |entry|
    file_name = File.join(project_root, '_papers', "#{entry.key}.md")
    if File.exist?(file_name)
      puts "File already exists: #{file_name}"
    else
      # Convert BibTeX object to hashmap
      e = {}
      entry.fields.each do |name, value|
        e[name.to_s] = value.to_s
      end

      # cleanup entry
      e = cleanup(e)

      # write to file
      content = ""
      content << e.to_yaml
      content << "---"

      File.write(file_name, content)
      puts "Write file: a #{file_name}"
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  bib_dir = Jekyll.configuration({})['papers']['bib_dir']
  bib_file = Jekyll.configuration({})['papers']['bib_file']
  create_files_from_bib(site.source, bib_dir, bib_file)
end
