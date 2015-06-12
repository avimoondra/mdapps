require 'rubygems'
require 'nokogiri'

class Profile

    def initialize(index)
        @page = Nokogiri::HTML(open("profiles/#{index}.html"))
        @userMetadata = @page.css(".viewprofileheader div:contains('Application Cycles')").text.gsub!(/\t/,' ')
        @uGradQualitativeMetadata = @page.css('div.subpagecontent p')[0].text.gsub!(/\t/,' ')
        @uGradQuantitativeMetadata = @page.css('div.subpagecontent p')[1].text.gsub!(/\t/,' ')
        @profile = self.set_profile()
    end

    def show
        puts @profile
    end

    def set_profile
        profile = {}
        keys = [:username, :id, :applicationCycle, :demographics, :homeState, :uGradCollege, :uGradAreaOfStudy, :mcat, :overallGPA, :scienceGPA, :briefProfile, :amcasSubmitted, :schools]
        for key in keys
            profile[key] = cleaner(key)
        end
        return profile
    end

    def cleaner(method)
        self.send(method)
    rescue => e
        return nil
    end

    def username
        username = @page.css('.viewprofileheader h1').text
    end

    def id
        id = @page.css('.viewprofileheader div')[0].text[5..-2]
    end

    def applicationCycle
        applicationCycle = /Application\sCycles:\s(?<date>.+)\n/.match(@userMetadata)['date'].strip
    end

    def demographics
        demographics = /Demographics:(?<demo>\s(\w+,?\s){1,})/.match(@userMetadata)['demo'].strip
    end

    def homeState
        # split this into gender, age, and race
        homeState = /Home State: (?<state>(\w+\s)+)/.match(@userMetadata)['state'].strip
    end

    def uGradCollege
        uGradCollege = /Undergraduate College: (.+)\n\s/.match(@uGradQualitativeMetadata)[1].strip
    end

    def uGradAreaOfStudy
        uGradAreaOfStudy = /Undergraduate Area of Study: (.+)\n\s/.match(@uGradQualitativeMetadata)[1].strip
    end

    def mcat
        mcat = /MCAT: (.+)\n/.match(@uGradQuantitativeMetadata)[1]
    end

    def overallGPA
        overallGPA = /Overall GPA: (.+)\n/.match(@uGradQuantitativeMetadata)[1]
    end

    def scienceGPA
       scienceGPA = /Science GPA: (.+)\n/.match(@uGradQuantitativeMetadata)[1]
    end

    def briefProfile
        briefProfile = @page.css('div.subpagecontent p')[2].text.gsub!(/\t/,' ')[20..-1].strip
    end

    def amcasSubmitted
        amcasSubmitted = /AMCAS submitted: (?<date>.+)/.match(@page.css('div.subpagecontent p')[3].text.gsub!(/\t/,' ').strip)['date'].strip
    end

    def schools
        schools = []
        for el in @page.css('div.subpagecontent a.arrow')
            school = {}

            school['name'] = el.text
            schoolId = el['id'][4..-1]
            schoolContent = @page.css('div#appspec_' + schoolId)

            school["Combined Phd/MSTP"] = /Combined PhD\/MSTP: (No|Yes)/.match(schoolContent.text)[1]

            for listel in schoolContent.css('li')
                key, value = listel.text.split(": ")
                school[key] = value
            end

            schools.push(school)
        end
        return schools
    end
end

for index in (0..1000).to_a
    p = Profile.new(index)
    puts p.show
end
