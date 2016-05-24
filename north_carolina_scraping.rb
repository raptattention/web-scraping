require 'nokogiri'
require 'open-uri'
require 'capybara-webkit'
require 'capybara/dsl'
require 'csv'
require 'mechanize'

include Capybara::DSL
Capybara.current_driver = :webkit
Capybara::Webkit.configure do |config|
  config.allow_url("apps.nccpaboard.gov")
end

CSV.open("nc_cpa.csv", "wb") do |csv|
	puts 'Starting to scrape North Carolina CPAs'
	csv << ["url", "name", "title", "email", "office", "practices", "education", "bar_admissions", "clerkships", "work", "work_count", "recognition", "recognition_count", "leadership", "leadership_count", "professional_experience", "publications", "publications_count", "speaking", "speaking_count"]
	count = 0
	while count < 35
		count = count + 1
		puts count
		page_link = 'http://www.goodwinprocter.com/Search-Results.aspx#q/sortby=Lastname&sortdirection=asc&sitesection=People&page=' + count.to_s
		visit(page_link)
		data = Nokogiri::HTML.parse(body)
		puts data.css('#paginationSummary').text
		table = data.css('#results > div') # in array, 250
		table.each do |item|
			link = item.css('div.partner-names > div.partner-name > a').map{ |a| a['href']}.compact.uniq
			if link[0].instance_of? String
				url = link[0]
				puts url
				event_content = Nokogiri::HTML(open(url).read)
				name = event_content.css('#employee-name').text.sub(/\s+/, "")
				name = name.sub(/\s+/, "")
				title = event_content.css('#mainform > div.main_content > div > div.three-of-four.column.column-add-gutter > div > div > div > div > div.employee-header > div.column.six-of-ten > div > p').text.sub(/\s+/, "")
				title.sub(/\s+/, "")
				email = event_content.css('#mainform > div.main_content > div > div.three-of-four.column.column-add-gutter > div > div > div > div > div.employee-header > div.column.six-of-ten > div > ul > li:nth-child(1) > strong > a > span.laime').text
				office = event_content.css('#mainform > div.main_content > div > div.three-of-four.column.column-add-gutter > div > div > div > div > div.employee-header > div.column.six-of-ten > div > ul > li:nth-child(2) > strong > a').text
				sidebar_content = event_content.css('#mainform > div.main_content > div > div.one-of-four.column-last > div')
				practices = ""
				education = ""
				bar_admissions = ""
				clerkships = ""
				sidebar_content.each do |sidebar|
					if sidebar.css('h2').text == "Practices"
						prac = sidebar.css('div > ul > li')
						prac.each do |p|
							practices << p.css('a').text+', '
						end
						practices.chomp(', ')
					elsif sidebar.css('h2').text == "Education"
						edu = sidebar.css('div > dl > dt')
						edu.each do |p|
							education << p.text+', '
						end
						education.chomp(', ')
					elsif sidebar.css('h2').text == "Admissions"
						admissions = sidebar.css('div > dl > dd:nth-child(2) > ul > li')
						admissions.each do |p|
							bar_admissions << p.text+', '
						end
						bar_admissions.chomp(', ')
					elsif sidebar.css('h2').text == "Clerkships"
						clerk = sidebar.css('div > dl > dd')
						clerk.each do |p|
							clerkships << p.text+', '
						end
						clerkships.chomp(', ')
					end
				end
				work = ""
				work_count = 0
				work_found = event_content.css('#phmaincontent_0_phcentercolumn_0_sltEmployeeBioAccordion_sltEmployeeWorkForClientsFold_pnlNoTabs > div > ul > li')
				work_found.each do |w|
					work << w.text + ";"
					work_count += 1
				end
				recognition = ""
				recognition_count = 0
				recognition_found = event_content.css('#phmaincontent_0_phcentercolumn_0_sltEmployeeBioAccordion_sltEmployeeRecognitionFold_pnlShowPanel a')
				recognition_found.each do |w|
					if (w.text != "Recognition")
						recognition << w.text + ";"
						recognition_count += 1
					end
				end
				leadership = ""
				leadership_count = 0
				leadership_found = event_content.css('#phmaincontent_0_phcentercolumn_0_sltEmployeeBioAccordion_sltEmployeeThoughtLeadershipFold_pnlShowPanel li')
				leadership_found.each do |w|
					leadership << w.text + ";"
					leadership_count += 1
				end
				professional_experience = ""
				professional_experience_found = event_content.css('#phmaincontent_0_phcentercolumn_0_sltEmployeeBioAccordion_sltEmployeeExperienceFold_pnlShowPanel p')
				professional_experience_found.each do |w|
					professional_experience << w.text + " "
				end
				publications = ""
				publications_count = 0
				publications_found = event_content.css('#phmaincontent_0_phcentercolumn_0_sltEmployeeBioAccordion_sltEmployeePublicationsFold_pnlShowPanel a')
				publications_found.each do |w|
					publications << w.text + ";"
					publications_count += 1
				end
				speaking = ""
				speaking_count = 0
				speaking_found = event_content.css('#phmaincontent_0_phcentercolumn_0_sltEmployeeBioAccordion_sltEmployeeSpeakingEngagementsFold_pnlShowPanel a')
				speaking_found.each do |w|
					speaking << w.text + ";"
					speaking_count += 1
				end
				puts name
				puts title			
				puts email
				puts office
				puts practices
				puts education
				puts bar_admissions
				puts clerkships
				puts work
				puts work_count
				puts recognition
				puts recognition_count
				puts leadership
				puts leadership_count
				puts professional_experience
				puts publications
				puts publications_count
				puts speaking
				puts speaking_count
				puts "---------------"
				csv << [url, name, title, email, office, practices, education, bar_admissions, clerkships, work, work_count, recognition, recognition_count, leadership, leadership_count, professional_experience, publications, publications_count, speaking, speaking_count]
			end
		end
	end
end
end