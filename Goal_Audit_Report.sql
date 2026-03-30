SELECT DISTINCT
         ppnf.FULL_NAME,
         papf.person_number,
         paam.assignment_number,
         HG.GOAL_NAME,
         TO_CHAR (HG.START_DATE, 'DD-Mon-YYYY', 'NLS_DATE_LANGUAGE = AMERICAN')
             AS GOAL_START_DATE,
         TO_CHAR (HG.TARGET_COMPLETION_DATE,
                  'DD-Mon-YYYY',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             AS GOAL_END_DATE,
         TO_CHAR (HG.LAST_UPDATE_DATE,
                  'DD-MON-YYYY HH24:MI:SS ',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             AS Last_Update_Date,
         (SELECT DISTINCT PPNF1.FULL_NAME
            FROM per_person_names_f PPNF1
           WHERE     HG.LAST_MODIFIED_BY = PPNF1.person_id
                 AND PPNF1.NAME_TYPE = 'GLOBAL'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PPNF1.EFFECTIVE_START_DATE)
                                         AND TRUNC (PPNF1.EFFECTIVE_END_DATE))
             AS LAST_UPDATED_BY,
         HG.LAST_UPDATED_BY
             AS Last_Update_By_ID,
         PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP ('HRG_GOAL_STATUS',
                                                 HG.STATUS_CODE)
             AS Goal_Status_Current --,(select  Replace(Replace(HN.NOTE_TEXT,'<p>',''),'</p>','')
                                   ,
         (SELECT TO_CHAR (
                     REPLACE (REPLACE (DBMS_LOB.SUBSTR(HN.NOTE_TEXT,4000,1), '<p>', ''), '</p>', ''))
            FROM HRT_NOTES HN
           WHERE     HN.CONTEXT_ID = HG.GOAL_ID
                 AND HN.CREATION_DATE = (SELECT MAX (HN1.CREATION_DATE)
                                           FROM HRT_NOTES HN1
                                          WHERE HN1.CONTEXT_ID = HN.CONTEXT_ID))
             COMMENTS,
         PPNF_MGR.FULL_NAME
             Manager_Name,
         (SELECT papf2.PERSON_NUMBER
            FROM PER_ALL_PEOPLE_F papf2
           WHERE     papf2.PERSON_ID = PPNF_MGR.PERSON_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf2.EFFECTIVE_START_DATE)
                                         AND TRUNC (papf2.EFFECTIVE_END_DATE)
                 AND ROWNUM = 1)
             AS MGR_ID,
         paam_mgr.ASSIGNMENT_NUMBER
             AS MANAGER_ASSIGNMENT_NUMBER,
         haoufvl_bu.name
             business_unit,
         haoufvl_dept.name
             department,
         (SELECT location_name
            FROM per_location_details_f_vl loc
           WHERE     loc.location_id = paam.location_id
                 AND TRUNC (SYSDATE) BETWEEN loc.effective_start_date
                                         AND loc.effective_end_date)
             location,
         haoufvl_le.name
             Legal_Employer,
         (SELECT geography_name
            FROM hz_geographies
           WHERE     geography_type = 'COUNTRY'
                 AND geography_code = PAAM.legislation_code
                 AND TRUNC (SYSDATE) BETWEEN start_date AND end_date)
             Legal_Emp_Country,
         (SELECT ppt.user_person_type
            FROM per_person_types_vl ppt
           WHERE     1 = 1
                 AND paam.person_type_id = ppt.person_type_id
                 AND ROWNUM = 1)
             person_type,
         PASTV.USER_STATUS
             ASSIGNMENT_STATUS,
         DECODE (paam.HOURLY_SALARIED_CODE,  'S', 'Salaried',  'H', 'Hourly')
             AS Hourly_or_Salaried,
         TO_CHAR (ppos.date_start, 'dd-Mon-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN')
             LE_Start_Date,
         TO_CHAR (PAAM.EFFECTIVE_START_DATE,
                  'DD-Mon-YYYY',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             Employee_Latest_Start_Date
    FROM 
         
         PER_PERSON_SECURED_LIST_V     PAPF,
         per_person_names_f            ppnf,
         per_all_assignments_m         paam,
         PER_ASSIGNMENT_STATUS_TYPES_VL PASTV,
         HRG_GOALS                     HG,
         HRT_REVIEW_PERIODS_VL         HRPL,
         HRG_GOAL_PLAN_GOALS           HGPG,
         PER_ASSIGNMENT_SUPERVISORS_F  PASF,
         PER_PERSON_NAMES_F            PPNF_MGR,
         per_all_assignments_m         paam_mgr,
         hr_all_organization_units_f_vl haoufvl_bu,
         hr_all_organization_units_f_vl haoufvl_dept,
         hr_all_organization_units_f_vl haoufvl_le,
         per_periods_of_service        ppos
   WHERE     1 = 1
         AND papf.person_id = paam.person_id
         AND papf.person_id = ppnf.person_id
         
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                 AND TRUNC (PAPF.EFFECTIVE_END_DATE)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAM.EFFECTIVE_START_DATE)
                                 AND TRUNC (PAAM.EFFECTIVE_END_DATE)
        AND TRUNC (SYSDATE) BETWEEN TRUNC (paam_mgr.EFFECTIVE_START_DATE)
                                 AND TRUNC (paam_mgr.EFFECTIVE_END_DATE)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PPNF.EFFECTIVE_START_DATE)
                                 AND TRUNC (PPNF.EFFECTIVE_END_DATE)
         AND PPNF.NAME_TYPE = 'GLOBAL'
         AND PAAM.ASSIGNMENT_TYPE = 'E'
         AND PAAM.ASSIGNMENT_STATUS_TYPE_ID =
             PASTV.ASSIGNMENT_STATUS_TYPE_ID(+)
         --AND PAAM.HOURLY_SALARIED_CODE='S'
         AND HG.PERSON_ID = PAPF.PERSON_ID
         AND HG.LAST_UPDATE_DATE BETWEEN (:P_EFF_DATE) - 1
                                     AND (:P_EFF_END_DATE) + 1
         AND HGPG.REVIEW_PERIOD_ID = HRPL.REVIEW_PERIOD_ID(+)
         AND HG.GOAL_ID = HGPG.GOAL_ID(+)
         AND PAAM.ASSIGNMENT_ID = PASF.ASSIGNMENT_ID
         AND PASF.MANAGER_TYPE = 'LINE_MANAGER'
         AND PASF.PRIMARY_FLAG = 'Y'
         AND PAAM.EFFECTIVE_LATEST_CHANGE='Y'
         AND PPNF_MGR.NAME_TYPE = 'GLOBAL'
         AND PASF.MANAGER_ID = PPNF_MGR.PERSON_ID
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PPNF_MGR.EFFECTIVE_START_DATE)
                                 AND TRUNC (PPNF_MGR.EFFECTIVE_END_DATE)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PASF.EFFECTIVE_START_DATE)
                                 AND TRUNC (PASF.EFFECTIVE_END_DATE)
         AND PASF.MANAGER_ASSIGNMENT_ID = paam_mgr.ASSIGNMENT_ID
         AND paam_mgr.EFFECTIVE_LATEST_CHANGE='Y'
         AND paam.business_unit_id = haoufvl_bu.organization_id
         AND TRUNC (SYSDATE) BETWEEN haoufvl_bu.effective_start_date
                                 AND haoufvl_bu.effective_end_date
         AND paam.organization_id = haoufvl_dept.organization_id(+)
         AND TRUNC (SYSDATE) BETWEEN haoufvl_dept.effective_start_Date(+)
                                 AND haoufvl_dept.effective_end_date(+)
         AND paam.legal_entity_id = haoufvl_le.organization_id
         AND TRUNC (SYSDATE) BETWEEN haoufvl_le.effective_start_date
                                 AND haoufvl_le.effective_end_date
         AND paam.person_id = ppos.person_id
         AND paam.period_of_service_id = ppos.period_of_service_id
         AND TO_CHAR (ppos.date_start, 'YYYYMMDD') =
             (SELECT TO_CHAR (MAX (ppos1.date_start), 'YYYYMMDD')
                FROM per_periods_of_service ppos1
               WHERE     ppos1.person_id = ppos.person_id
                     
                     AND PPOS1.PERIOD_TYPE IN ('E')
                     AND TRUNC (PPOS1.DATE_START) <= TRUNC (SYSDATE))
         AND PPOS.PERIOD_TYPE IN ('E')
         AND HG.LAST_UPDATE_DATE BETWEEN :P_EFF_DATE AND :P_EFF_END_DATE + 1
         AND (   HRPL.REVIEW_PERIOD_NAME IN (:REVIEW_PERIOD_NAME)
              OR (LEAST (:REVIEW_PERIOD_NAME) IS NULL))
         AND (   PPNF.PERSON_ID IN (:PERSON_NAME)
              OR (LEAST (:PERSON_NAME) IS NULL))
         AND (   Papf.PERSON_ID IN (:PERSON_NUMBER)
              OR (LEAST (:PERSON_NUMBER) IS NULL))
         AND (   PASTV.USER_STATUS IN (:ASSIGNMENT_STATUS)
              OR (LEAST (:ASSIGNMENT_STATUS) IS NULL))
         AND (PAAM.BUSINESS_UNIT_ID IN (:BU_UNIT) OR (LEAST (:BU_UNIT) IS NULL))
         AND (   PAAM.LEGAL_ENTITY_ID IN (:EMPLOYEE_LEGAL_EMPLOYER)
              OR (LEAST (:EMPLOYEE_LEGAL_EMPLOYER) IS NULL))
         AND (   PAAM.ORGANIZATION_ID IN (:EMPLOYEE_DEPARTMENT)
              OR (LEAST (:EMPLOYEE_DEPARTMENT) IS NULL))
         AND (   PASF.MANAGER_ID IN (:MANAGER_NAME)
              OR (LEAST (:MANAGER_NAME) IS NULL))

ORDER BY Last_Update_Date ASC