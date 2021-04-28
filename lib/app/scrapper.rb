require 'bundler'
Bundler.require

class Scrapper
    
    def get_townhall_url
    page = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/val-d-oise.html"))
 
    @mairies_nameS = page.xpath('//td[1]/p/a | //td[2]/p/a | //td[3]/p/a').map do |mairie|
      mairie.text.downcase.tr(' ','-')
    end
  end
 
  def get_townhall_email
    mairies_mailS = @mairies_nameS.map do |ville|
      page_2 = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/95/#{ville}.html"))
        page_2.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').map do |mail|
        mail.content
      end
    end
  end 
 
  def hash(mairies_nameS, mairies_mailS)
    my_hash = Hash[mairies_nameS.zip(mairies_mailS)]
  end
 
    def save_as_json
    File.open("db/mails.json","w") do |f|
        f.write(JSON.pretty_generate(hash(get_townhall_url, get_townhall_email)))
      end
      
    end

def save_as_spreadsheet
    
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1EJ-oXQy4JQF1txReNGbVhvhB2XZisXiT_84Lx8lqS1w").worksheets[0]

    ws.insert_rows(1, [get_townhall_url])
    ws.insert_rows(2, [get_townhall_email])
    ws.save
      
end

def save_as_csv
    
    File.open('db/data.csv', 'w') do |row|
        row << hash(get_townhall_url,get_townhall_email)
       end
      
end

def perform
    get_townhall_url
    get_townhall_email
    hash(get_townhall_url, get_townhall_email)
    save_as_spreadsheet
    save_as_csv
end

end




    



 