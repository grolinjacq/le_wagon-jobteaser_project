# le_wagon-jobteaser_project
This repository stores the SQL queries done on our final project about JobTeaser at le Wagon

## Description
[Jobteaser](https://www.jobteaser.com/) has developed a matching tool between students and companies. The goal is to help students find their first job. The Jobteaser algorithm picks up to 20 candidates for a given job offer. Students answer whether they are interested or not, and the company selects candidates among the interested students. The funnel is as follows:

- opt-in
- opt-in qualified (students upload their CV, which is mandatory to be shortlisted)
- shortlisted
- students having answered (*status_update interested or not)*
- students being interested (*status_update interested*)
- companies having answered
- companies having approved

Analyze the funnel and drops. Formulate business hypotheses and verify them with data. Provide recommendations.

## Data Sources & Description

- **optin**: contains all students opt-in/opt-out info. This is a toggle to activate saying that we are "looking for opportunities" and therefore agree to receive offers from companies via Shortlist product.
    - *user_id*
    - *receive_time*
    - *cause*:
        - *manual:* student manually opt-in/opt-out toggle
        - *auto-no-answer:* student doesn’t answer to a Shortlist, he is automatically opt-out
    - *active*: TRUE if it’s opt-in FALSE otherwise
    - *school_id*
    - *current_sign_in_at*: last student connection date
    - *resume_uploaded*

    https://docs.google.com/spreadsheets/d/1LsgS763ksZNOJf_44Pafz2pwSZRSo8h3gntjKmEejhY/edit?usp=sharing

- **candidate_status_update:** contains all responses from shortlisted students, as well as responses from recruiters after students have declared their interest in the offer.
    - *user_id*
    - *receive_time*: event timestamp
    - *shortlist_id*
    - *status_update*:
        - Student side:
            - awaiting: waiting for student answer
            - *interested*: student is interested in the offer and agrees to send his/her CV to the recruiter
            - *not interested*: student is not interested or did not answer
        - Company_side:
            - *approved*: recruiter has validated the student's CV and begins the recruitment process
            - *declined*: recruiter is finally not interested in the student
        
        response is optional, unlike the student who, if he or she does not respond, falls into the not interested category by default.
        
    - *cause*:
        - *email-click:* student or recruiter made the action
        - *auto-timeout:* after 72h of no response (student side only)
    - *school_id*: school_id of the student
    - *current_sign_in_at:* last student connection date

    https://docs.google.com/spreadsheets/d/1aa906blQHkqyCrHP9QNO5XfYJX8u8m0ipwkR8yH-G0s/edit?usp=sharing

- d**im_schools:** table contains all information about JT's partner schools.
    - *school_id*
    - *is_cc*: is it the career center of the school or JT public site
    - *intranet_school_id*: in case it is a public site, here is the id of the school with career center. For example, ESSEC is a partner school with a career center. However, if I am an alumni, I will no longer have access to the career center, so I will be able to register on JT via the public site. My school_id will be the one of ESSEC on the public site, and in the intranet_school_id column, the id of the ESSEC career center will appear
    - *jt_country*: school country
    - *jt_intranet_status*: only “launched” status matters to you, and means that the school has an integrated career center via JT. Otherwise it is the public site, with statuses corresponding to the different levels of advancement of the prospects.
    - *jt_school_type*: School type
        - 1 : Engineer Schools / TU
        - 2 : Business Schools / Business Universities
        - 3 : Other Universities
        - Other

    https://docs.google.com/spreadsheets/d/1N30oSo-wSrAOhjwCKo07BrraASWHsI9sUIVRTJuntmQ/edit?usp=sharing

## Analysis Result

Link to Presentation: https://www.canva.com/design/DAFlJjLpfBg/DOX_J9pjDtgE5j90sdpmQw/edit?utm_content=DA[…]m_campaign=designshare&utm_medium=link2&utm_source=sharebutton