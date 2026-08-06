-- =============================================================================
-- migration_step6_patients_2023_2025.sql
-- =============================================================================
-- Inserts patients PRODONT311 through PRODONT521 (skipping PRODONT503, PRODONT513)
-- into auth.users, auth.identities, and public.patients.
--
-- Patient count : 209 patients
-- Run order     : Step 6 (after Steps 1-5)
-- Safe to re-run: YES (all inserts are guarded with WHERE NOT EXISTS)
-- =============================================================================

DO $$
DECLARE
  v_user_id UUID;
  v_email   TEXT;
  v_phone   TEXT;
  v_code    TEXT;
  v_fname   TEXT;
  v_lname   TEXT;
  v_gender  TEXT;
  v_dob     DATE;
  r         RECORD;
BEGIN
  FOR r IN (
    SELECT * FROM (VALUES
      ('PRODONT311', 'Naren', NULL::TEXT, '9704770771', 'naren.katneni@gmail.com', 'Male', NULL::TEXT),
      ('PRODONT312', 'Umamaheswar', 'V', '9989067555', '9989067555@prodontics.in', 'Male', '1955-07-01'),
      ('PRODONT313', 'Chaitanya', NULL, '8790205050', '8790205050@prodontics.in', 'Male', NULL),
      ('PRODONT314', 'Kavitha', 'S', '9912619201', '9912619201@prodontics.in', 'Female', '1985-01-01'),
      ('PRODONT315', 'Hari', 'Krishna', '9980200778', '9980200778@prodontics.in', 'Male', NULL),
      ('PRODONT316', 'Vandana', 'Tamirisa', '9989548667', '9989548667@prodontics.in', 'Female', NULL),
      ('PRODONT317', 'Sudheer', 'C', '7780102273', '7780102273@prodontics.in', 'Male', NULL),
      ('PRODONT318', 'ramya', 'p', '9490556555', '9490556555@prodontics.in', 'Male', NULL),
      ('PRODONT319', 'Eshana', 'Singh', '7838039370', '7838039370@prodontics.in', 'Female', NULL),
      ('PRODONT320', 'Sasmita', NULL, '9090826829', '9090826829@prodontics.in', 'Female', NULL),
      ('PRODONT321', 'CHAITANYA', NULL, '8790205050', '8790205050_2@prodontics.in', 'Male', NULL),
      ('PRODONT322', 'Raja', 'Gangaputra', '9063880361', '9063880361@prodontics.in', 'Male', NULL),
      ('PRODONT323', 'Sri', 'Karamakonda', '9063880361', '9063880361_2@prodontics.in', 'Female', NULL),
      ('PRODONT324', 'Radha', 'Gangaputra', '9063880361', '9063880361_3@prodontics.in', 'Female', NULL),
      ('PRODONT325', 'Eshwaraiah', 'Gangaputra', '9063880361', '9063880361_4@prodontics.in', 'Male', NULL),
      ('PRODONT326', 'Srinivas', 'S', '9481648756', '9481648756@prodontics.in', 'Male', NULL),
      ('PRODONT327', 'Kishore', NULL, '9704378745', '9704378745@prodontics.in', 'Male', NULL),
      ('PRODONT328', 'Bharath', 'A', '9640121036', '9640121036@prodontics.in', 'Male', NULL),
      ('PRODONT329', 'GV pelli', NULL, '9490556555', '9490556555_2@prodontics.in', 'Male', NULL),
      ('PRODONT330', 'Santosh reddy', 'R', '8106004463', '8106004463@prodontics.in', 'Male', NULL),
      ('PRODONT331', 'Karthikeyan', 'Komar', '8754464231', '8754464231@prodontics.in', 'Male', NULL),
      ('PRODONT332', 'Sai', 'Pramod', '9010593882', '9010593882@prodontics.in', 'Male', NULL),
      ('PRODONT333', 'Harika', NULL, '9848322371', '9848322371@prodontics.in', 'Female', NULL),
      ('PRODONT334', 'Sridhar', NULL, '9010133000', '9010133000@prodontics.in', 'Male', NULL),
      ('PRODONT335', 'Rajitha', NULL, '9573092300', '9573092300@prodontics.in', 'Female', NULL),
      ('PRODONT336', 'Deepanshu', 'L', '7507295462', '7507295462@prodontics.in', 'Male', NULL),
      ('PRODONT337', 'Sruthi', 'Chennuri', '7702958363', '7702958363@prodontics.in', 'Female', NULL),
      ('PRODONT338', 'Pranav', 'Raj', '7350007672', '7350007672@prodontics.in', 'Male', NULL),
      ('PRODONT339', 'Ganesh', 'KN', '9642749620', '9642749620@prodontics.in', 'Male', NULL),
      ('PRODONT340', 'Sharol', 'Rodrigues', '8884654499', '8884654499@prodontics.in', 'Female', NULL),
      ('PRODONT341', 'Chaitanya', NULL, '9000070787', '9000070787@prodontics.in', 'Male', NULL),
      ('PRODONT342', 'Rajini', NULL, '9241665094', '9241665094@prodontics.in', 'Female', NULL),
      ('PRODONT343', 'Srikar', NULL, '8639251838', '8639251838@prodontics.in', 'Male', NULL),
      ('PRODONT344', 'Sonia', NULL, '8367451441', '8367451441@prodontics.in', 'Female', NULL),
      ('PRODONT345', 'Sai', 'Adwaith', '9502737135', '9502737135@prodontics.in', 'Male', NULL),
      ('PRODONT346', 'Hasini', 'K', '7013086333', '7013086333@prodontics.in', 'Female', NULL),
      ('PRODONT347', 'Ashwini', 'Kumar', '9703668725', '9703668725@prodontics.in', 'Male', NULL),
      ('PRODONT348', 'Neelu', 'Sunny', '9446741373', '9446741373@prodontics.in', 'Female', NULL),
      ('PRODONT349', 'DILEEP', 'KUMAR', '9014854007', '9014854007@prodontics.in', 'Male', NULL),
      ('PRODONT350', 'Achyuth', 'Keshav', '9701204630', '9701204630@prodontics.in', 'Female', '2024-09-13'),
      ('PRODONT351', 'Noora', NULL, '8106919076', '8106919076@prodontics.in', 'Female', NULL),
      ('PRODONT352', 'Dithya', 'Reddy', '9666640908', '9666640908@prodontics.in', 'Female', NULL),
      ('PRODONT353', 'Nysha', 'B', '9885031402', '9885031402@prodontics.in', 'Female', NULL),
      ('PRODONT354', 'Sudhakar', NULL, '9010593882', '9010593882_2@prodontics.in', 'Male', NULL),
      ('PRODONT355', 'Chandrashekhar', 'Reddy', '8125960584', '8125960584@prodontics.in', 'Female', NULL),
      ('PRODONT356', 'Arun', 'Gupta', '8007678890', '8007678890@prodontics.in', 'Male', NULL),
      ('PRODONT357', 'Harsha', 'Akkenepally', '9032199637', '9032199637@prodontics.in', 'Male', NULL),
      ('PRODONT358', 'Dr.', 'Abhigna', '8978190918', '8978190918@prodontics.in', 'Female', NULL),
      ('PRODONT359', 'Vijayalakshmi', NULL, '8897966969', '8897966969@prodontics.in', 'Female', NULL),
      ('PRODONT360', 'Ram', 'Mallik', '9676104710', '9676104710@prodontics.in', 'Male', NULL),
      ('PRODONT361', 'Lizzy', 'Sanvitha', '8121019719', '8121019719@prodontics.in', 'Female', NULL),
      ('PRODONT362', 'Aanchal', 'Grover', '9665342189', '9665342189@prodontics.in', 'Female', NULL),
      ('PRODONT363', 'Vimal', NULL, '8897860245', '8897860245@prodontics.in', 'Male', NULL),
      ('PRODONT364', 'Eeswari', NULL, '9177999846', '9177999846@prodontics.in', 'Female', NULL),
      ('PRODONT365', 'Nisha', 'mishra', '9000509178', '9000509178@prodontics.in', 'Female', NULL),
      ('PRODONT366', 'Anjali', NULL, '8489696737', '8489696737@prodontics.in', 'Female', NULL),
      ('PRODONT367', 'Venkat', 'Reddy', '9881255085', '9881255085@prodontics.in', 'Male', NULL),
      ('PRODONT368', 'Arjun', 'Vodala', '9177999846', '9177999846_2@prodontics.in', 'Female', NULL),
      ('PRODONT369', 'VENKAT', 'REDDY', '9881255085', '9881255085_2@prodontics.in', 'Male', NULL),
      ('PRODONT370', 'Ajaz', NULL, '8555834406', '8555834406@prodontics.in', 'Male', NULL),
      ('PRODONT371', 'Venkat', 'Reddy', '9881255085', '9881255085_3@prodontics.in', 'Male', NULL),
      ('PRODONT372', 'Sridhar', 'Rudraraju', '9010133000', '9010133000_2@prodontics.in', 'Male', NULL),
      ('PRODONT373', 'Achyuth', 'Ram', '9652165458', '9652165458@prodontics.in', 'Male', NULL),
      ('PRODONT374', 'Santosh', 'J', '9952918915', '9952918915@prodontics.in', 'Male', NULL),
      ('PRODONT375', 'Vaiyshnavi', 'S', '9751482384', '9751482384@prodontics.in', 'Female', '1996-01-01'),
      ('PRODONT376', 'Sravanthi', 'Parisha', '8897886900', '8897886900@prodontics.in', 'Female', NULL),
      ('PRODONT377', 'Saathwika', NULL, '9000016395', '9000016395@prodontics.in', 'Female', NULL),
      ('PRODONT378', 'P Vishwath', 'Reddy', '9701715473', '9701715473@prodontics.in', 'Male', NULL),
      ('PRODONT379', 'Sravan', NULL, '9640121036', '9640121036_2@prodontics.in', 'Female', NULL),
      ('PRODONT380', 'Raghu', 'Thadakamalla', '9032514586', '9032514586@prodontics.in', 'Male', NULL),
      ('PRODONT381', 'Aryash', '(c/o Ms. Shanti)', '8790073465', '8790073465@prodontics.in', 'Male', NULL),
      ('PRODONT382', 'DEEPTHI', 'G', '9703027737', '9703027737@prodontics.in', 'Female', NULL),
      ('PRODONT383', 'Nisha', 'Mishra', '9000509178', '9000509178_2@prodontics.in', 'Female', NULL),
      ('PRODONT384', 'Varnika', NULL, '9620423367', '9620423367@prodontics.in', 'Female', NULL),
      ('PRODONT385', 'Yeshwanth', NULL, '9963337925', '9963337925@prodontics.in', 'Male', NULL),
      ('PRODONT386', 'Goli', 'Varnika', '9703030768', '9703030768@prodontics.in', 'Female', NULL),
      ('PRODONT387', 'Kranthi', NULL, '8790399083', '8790399083@prodontics.in', 'Female', NULL),
      ('PRODONT388', 'Guddi', 'Langroo', '7702933996', '7702933996@prodontics.in', 'Female', NULL),
      ('PRODONT389', 'Rajeev', 'Solmon', '7799992893', '7799992893@prodontics.in', 'Male', NULL),
      ('PRODONT390', 'Adith', 'Aryan', '7893197999', '7893197999@prodontics.in', 'Male', NULL),
      ('PRODONT391', 'PRATHIGADAPA', 'RAJU', '8008896416', '8008896416@prodontics.in', 'Male', NULL),
      ('PRODONT392', 'Ekta', 'Mohapatra', '7411979683', '7411979683@prodontics.in', 'Female', '2020-01-01'),
      ('PRODONT393', 'Kiara', NULL, '9989928381', '9989928381@prodontics.in', 'Female', NULL),
      ('PRODONT394', 'Yoihenba Waikhom', NULL, '9366193397', '9366193397@prodontics.in', 'Male', NULL),
      ('PRODONT395', 'Bikash', 'Agarwal', '9832708499', '9832708499@prodontics.in', 'Male', NULL),
      ('PRODONT396', 'Monika', NULL, '8297996644', '8297996644@prodontics.in', 'Female', NULL),
      ('PRODONT397', 'KS', 'RAMESH', '9848022515', '9848022515@prodontics.in', 'Male', NULL),
      ('PRODONT398', 'Shaarath', 'vihari', '9704533332', '9704533332@prodontics.in', 'Male', NULL),
      ('PRODONT399', 'Chandana', NULL, '9704533332', '9704533332_2@prodontics.in', 'Female', NULL),
      ('PRODONT400', 'Karthikeyan', 'Kumar', '8754464231', '8754464231_2@prodontics.in', 'Female', NULL),
      ('PRODONT401', 'Sree', 'Chaya', '9700926060', '9700926060@prodontics.in', 'Female', NULL),
      ('PRODONT402', 'Sarita', 'Dhankar', '7093002427', '7093002427@prodontics.in', 'Female', NULL),
      ('PRODONT403', 'Koyya', 'Pallavi', '9177258258', '9177258258@prodontics.in', 'Female', NULL),
      ('PRODONT404', 'Parthiv', 'Konda', '8142574254', '8142574254@prodontics.in', 'Male', NULL),
      ('PRODONT405', 'Subhash', 'Konda', '8142574254', '8142574254_2@prodontics.in', 'Male', NULL),
      ('PRODONT406', 'Sridevi', NULL, '9334010101', '9334010101@prodontics.in', 'Female', NULL),
      ('PRODONT407', 'Sudheera', NULL, '9916201716', '9916201716@prodontics.in', 'Female', NULL),
      ('PRODONT408', 'KRISHNA', 'N', '9908835999', '9908835999@prodontics.in', 'Female', NULL),
      ('PRODONT409', 'Mallikharjun', 'V', '7675936600', '7675936600@prodontics.in', 'Male', NULL),
      ('PRODONT410', 'Sahaj', 'Dhruv', '9000577844', '9000577844@prodontics.in', 'Male', NULL),
      ('PRODONT411', 'Priyanka', 'Eslavath', '7893098833', '7893098833@prodontics.in', 'Female', NULL),
      ('PRODONT412', 'Rashmin', 'Shoury', '9985308866', '9985308866@prodontics.in', 'Male', NULL),
      ('PRODONT413', 'CH.', 'Rao', '9908437529', '9908437529@prodontics.in', 'Male', '1969-10-02'),
      ('PRODONT414', 'Geeta', NULL, '9986811339', '9986811339@prodontics.in', 'Female', NULL),
      ('PRODONT415', 'Bhaskar', 'Reddy', '8008822240', '8008822240@prodontics.in', 'Female', NULL),
      ('PRODONT416', 'Anitha', NULL, '9866079155', '9866079155@prodontics.in', 'Female', NULL),
      ('PRODONT417', 'Nisha', 'Mishra', '9000509178', '9000509178_3@prodontics.in', 'Female', NULL),
      ('PRODONT418', 'BHIMALINGAM', 'LAKSHMI', '9773903622', '9773903622@prodontics.in', 'Female', NULL),
      ('PRODONT419', 'Sanjeev', NULL, '8886886938', '8886886938@prodontics.in', 'Male', NULL),
      ('PRODONT420', 'Lakshmi', NULL, '9618037923', '9618037923@prodontics.in', 'Female', NULL),
      ('PRODONT421', 'Naresh', 'Reddy', '9740168508', '9740168508@prodontics.in', 'Male', NULL),
      ('PRODONT422', 'Surya', NULL, '9490556555', '9490556555_3@prodontics.in', 'Male', NULL),
      ('PRODONT423', 'Khushbu', 'Pujara', '9898997084', '9898997084@prodontics.in', 'Female', NULL),
      ('PRODONT424', 'M', 'Mukarram', '9247206025', '9247206025@prodontics.in', 'Male', NULL),
      ('PRODONT425', 'Aathmik', 'Bondalapati', '9600008888', '9600008888@prodontics.in', 'Male', NULL),
      ('PRODONT426', 'Rahul', 'R', '9700002526', '9700002526@prodontics.in', 'Male', NULL),
      ('PRODONT427', 'Keshav', 'K', '9676766199', '9676766199@prodontics.in', 'Male', NULL),
      ('PRODONT428', 'Venkat', 'Yerragudi', '9986811339', '9986811339_2@prodontics.in', 'Male', NULL),
      ('PRODONT429', 'Aaryav', 'Pujara', '9898997084', '9898997084_2@prodontics.in', 'Male', NULL),
      ('PRODONT430', 'Arnav', NULL, '9052399299', '9052399299@prodontics.in', 'Male', NULL),
      ('PRODONT431', 'Smrithi', 'Reddy', '9247883625', '9247883625@prodontics.in', 'Female', NULL),
      ('PRODONT432', 'Dr. Sanjana', NULL, '7330953999', '7330953999@prodontics.in', 'Female', NULL),
      ('PRODONT433', 'Y', 'Devi', '9866257287', '9866257287@prodontics.in', 'Female', NULL),
      ('PRODONT434', 'Krishnaveni', 'R', '8790267481', '8790267481@prodontics.in', 'Female', NULL),
      ('PRODONT435', 'Radha', 'Mohan', '9440918122', '9440918122@prodontics.in', 'Male', NULL),
      ('PRODONT436', 'Rama', 'Lakshmi', '8790205050', '8790205050_3@prodontics.in', 'Female', NULL),
      ('PRODONT437', 'Neelima', NULL, '9731570703', '9731570703@prodontics.in', 'Female', NULL),
      ('PRODONT438', 'Nayana', NULL, '9959918818', '9959918818@prodontics.in', 'Female', NULL),
      ('PRODONT439', 'Shri', 'Bhatt', '9963028101', '9963028101@prodontics.in', 'Male', NULL),
      ('PRODONT440', 'Anushri', NULL, '8106444815', '8106444815@prodontics.in', 'Female', NULL),
      ('PRODONT441', 'Goli', 'Reddy', '9620423367', '9620423367_2@prodontics.in', 'Male', NULL),
      ('PRODONT442', 'Mousumi', 'Pal', '9036325436', '9036325436@prodontics.in', 'Female', NULL),
      ('PRODONT443', 'Anusha', NULL, '7702377555', '7702377555@prodontics.in', 'Female', NULL),
      ('PRODONT444', 'Vijaya', 'Lakshmi', '8885576500', '8885576500@prodontics.in', 'Female', NULL),
      ('PRODONT445', 'Symantika', 'Gaurav', '9989928381', '9989928381_2@prodontics.in', 'Female', NULL),
      ('PRODONT446', 'Arshita', 'Agnihotri', '9669911101', '9669911101@prodontics.in', 'Female', NULL),
      ('PRODONT447', 'Shubhadha', 'D', '8106230703', '8106230703@prodontics.in', 'Male', '1981-06-11'),
      ('PRODONT448', 'Shubhadha', 'D', '8106230703', '8106230703_2@prodontics.in', 'Female', NULL),
      ('PRODONT449', 'Hamdan', 'Siddiqui', '9966144471', '9966144471@prodontics.in', 'Male', NULL),
      ('PRODONT450', 'Alekhya', 'B', '7675936600', '7675936600_2@prodontics.in', 'Female', NULL),
      ('PRODONT451', 'Abhilash', 'Reddy', '9959659583', '9959659583@prodontics.in', 'Male', NULL),
      ('PRODONT452', 'Anatoli', NULL, '9106675686', '9106675686@prodontics.in', 'Female', NULL),
      ('PRODONT453', 'Karthik', 'M', '8247338919', '8247338919@prodontics.in', 'Male', NULL),
      ('PRODONT454', 'Hasini', 'Kalwoji', '7013086333', '7013086333_2@prodontics.in', 'Female', NULL),
      ('PRODONT455', 'Poulomi', NULL, '9599229168', '9599229168@prodontics.in', 'Female', NULL),
      ('PRODONT456', 'Maddela', 'Harshitha', '7032472052', '7032472052@prodontics.in', 'Female', NULL),
      ('PRODONT457', 'Bharath', 'M', '9985333392', '9985333392@prodontics.in', 'Male', NULL),
      ('PRODONT458', 'Sindhuri', 'S', '9000293856', '9000293856@prodontics.in', 'Female', NULL),
      ('PRODONT459', 'Rajesh', 'Rai', '7780110782', '7780110782@prodontics.in', 'Male', NULL),
      ('PRODONT460', 'T', 'Reddy', '9912157154', '9912157154@prodontics.in', 'Male', NULL),
      ('PRODONT461', 'Manisha', 'Singh', '8527679710', '8527679710@prodontics.in', 'Female', NULL),
      ('PRODONT462', 'Jaya', 'lakshmi', '9742727312', '9742727312@prodontics.in', 'Female', NULL),
      ('PRODONT463', 'Rithik', NULL, '9100991790', '9100991790@prodontics.in', 'Male', NULL),
      ('PRODONT464', 'Rishika', NULL, '7674008030', '7674008030@prodontics.in', 'Female', NULL),
      ('PRODONT465', 'Vineela', 'K', '9533523907', '9533523907@prodontics.in', 'Female', NULL),
      ('PRODONT466', 'Jani', 'Kalidindi', '9666411111', '9666411111@prodontics.in', 'Male', '1967-01-01'),
      ('PRODONT467', 'Birendra', 'Suthar', '9581002105', '9581002105@prodontics.in', 'Male', NULL),
      ('PRODONT468', 'Srujan', 'L', '9032468304', '9032468304@prodontics.in', 'Male', NULL),
      ('PRODONT469', 'Anvitha', 'K', '8886239999', '8886239999@prodontics.in', 'Female', NULL),
      ('PRODONT470', 'Sanjana', 'Reddy', '9121224999', '9121224999@prodontics.in', 'Female', NULL),
      ('PRODONT471', 'Mahendra', 'Singh', '8897535884', '8897535884@prodontics.in', 'Male', NULL),
      ('PRODONT472', 'Niharika', NULL, '9966512889', '9966512889@prodontics.in', 'Female', NULL),
      ('PRODONT473', 'Vineela', NULL, '9989067555', '9989067555_2@prodontics.in', 'Female', NULL),
      ('PRODONT474', 'Amber', 'kumar', '9701204630', '9701204630_2@prodontics.in', 'Male', NULL),
      ('PRODONT475', 'P. L.', 'Yashodhara', '9440000575', '9440000575@prodontics.in', 'Female', NULL),
      ('PRODONT476', 'Ridhima', 'V', '9849496677', '9849496677@prodontics.in', 'Female', NULL),
      ('PRODONT477', 'Anu', NULL, '9703261142', '9703261142@prodontics.in', 'Female', NULL),
      ('PRODONT478', 'G', 'Reddy', '9393415511', '9393415511@prodontics.in', 'Female', NULL),
      ('PRODONT479', 'Jhansi', 'M', '9440918250', '9440918250@prodontics.in', 'Female', NULL),
      ('PRODONT480', 'Nithya', 'T', '8452843840', '8452843840@prodontics.in', 'Female', NULL),
      ('PRODONT481', 'Rajasekhar', 'Kambhampati', '7075550738', '7075550738@prodontics.in', 'Male', NULL),
      ('PRODONT482', 'Moukthika', NULL, '8790205050', '8790205050_4@prodontics.in', 'Female', NULL),
      ('PRODONT483', 'NOOKALA LAKSHMI', 'GOWRI', '7893509084', '7893509084@prodontics.in', 'Female', NULL),
      ('PRODONT484', 'Bharathi', NULL, '9403688815', '9403688815@prodontics.in', 'Female', NULL),
      ('PRODONT485', 'K.N.S', NULL, '9440918122', '9440918122_2@prodontics.in', 'Male', NULL),
      ('PRODONT486', 'Pawan', NULL, '8297764586', '8297764586@prodontics.in', 'Male', NULL),
      ('PRODONT487', 'Kalpana', 'Prasad', '7032806328', '7032806328@prodontics.in', 'Female', NULL),
      ('PRODONT488', 'Shiva', NULL, '9949492333', '9949492333@prodontics.in', 'Male', NULL),
      ('PRODONT489', 'Pranav', NULL, '9949492333', '9949492333_2@prodontics.in', 'Male', NULL),
      ('PRODONT490', 'Hrishi', 'Reddy', '9398695501', '9398695501@prodontics.in', 'Female', NULL),
      ('PRODONT491', 'S', 'NAGA JYOTHI', '9676104710', '9676104710_2@prodontics.in', 'Female', NULL),
      ('PRODONT492', 'Vidyullatha', 'Mulpuri', '9492126044', '9492126044@prodontics.in', 'Female', NULL),
      ('PRODONT493', 'Maruthi', 'Prakash', '9989114893', '9989114893@prodontics.in', 'Male', NULL),
      ('PRODONT494', 'Divyadharshini', 'Natarajan', '6380906045', '6380906045@prodontics.in', 'Female', NULL),
      ('PRODONT495', 'Aditya', 'Pagadala', '9676170329', '9676170329@prodontics.in', 'Male', NULL),
      ('PRODONT496', 'Nitin', 'Sharma', '7838760042', '7838760042@prodontics.in', 'Male', '1987-04-27'),
      ('PRODONT497', 'Saahas', 'Vankayalapati', '9901099944', '9901099944@prodontics.in', 'Male', NULL),
      ('PRODONT498', 'M. S. BHARATHI', NULL, '9403688815', '9403688815_2@prodontics.in', 'Female', NULL),
      ('PRODONT499', 'Rama', 'Deepthi', '8790620114', '8790620114@prodontics.in', 'Female', NULL),
      ('PRODONT500', 'Shiju', 'Nambiar', '8790620114', '8790620114_2@prodontics.in', 'Male', NULL),
      ('PRODONT501', 'Koya', 'Madhu', '9743060500', '9743060500@prodontics.in', 'Male', NULL),
      ('PRODONT502', 'Baddepudi', 'Prasad', '9291506731', '9291506731@prodontics.in', 'Male', NULL),
      ('PRODONT504', 'Baddepudi', 'Kumar', '9291506731', '9291506731_3@prodontics.in', 'Male', NULL),
      ('PRODONT505', 'Murali', 'Krishna C', '9948223399', '9948223399@prodontics.in', 'Male', NULL),
      ('PRODONT506', 'Shweta', 'Desai', '9000025444', '9000025444@prodontics.in', 'Female', NULL),
      ('PRODONT507', 'Akshatha', NULL, '9618672588', '9618672588@prodontics.in', 'Female', NULL),
      ('PRODONT508', 'Shresta', NULL, '9440722986', '9440722986@prodontics.in', 'Female', NULL),
      ('PRODONT509', 'RANJU', 'SOOD', '9553681698', '9553681698@prodontics.in', 'Female', NULL),
      ('PRODONT510', 'Sai Sindhu', NULL, '9502309068', '9502309068@prodontics.in', 'Female', NULL),
      ('PRODONT511', 'B SREENIVAS', NULL, '9686866011', '9686866011@prodontics.in', 'Male', NULL),
      ('PRODONT512', 'SHIVA', 'K', '7799683344', '7799683344@prodontics.in', 'Female', NULL),
      ('PRODONT514', 'SUDHEER KUMAR', 'BAKI', '9986865141', '9986865141@prodontics.in', 'Male', NULL),
      ('PRODONT515', 'SANDEEP SINGH', NULL, '7702933998', '7702933998@prodontics.in', 'Male', NULL),
      ('PRODONT516', 'BHUVANESHWARI', NULL, '9869174750', '9869174750@prodontics.in', 'Female', NULL),
      ('PRODONT517', 'MANMOHAN', 'REDDY', '9502952144', '9502952144@prodontics.in', 'Male', NULL),
      ('PRODONT518', 'Srinivas', 'Alla', '9731140434', '9731140434@prodontics.in', 'Male', NULL),
      ('PRODONT519', 'Savithri Bhatt', NULL, '9963028101', '9963028101_2@prodontics.in', 'Female', NULL),
      ('PRODONT520', 'A. RAVINDER RAO', NULL, '9492675494', '9492675494@prodontics.in', 'Male', NULL),
      ('PRODONT521', 'Sirivennela Dara', NULL, '7093943007', '7093943007@prodontics.in', 'Female', NULL)
    ) AS t(code, fname, lname, phone, email, gender, dob)
  ) LOOP
    v_code   := r.code;
    v_fname  := r.fname;
    v_lname  := r.lname;
    v_phone  := r.phone;
    v_email  := r.email;
    v_gender := r.gender;
    v_dob    := CASE WHEN r.dob IS NOT NULL THEN r.dob::DATE ELSE NULL END;

    -- Skip if patient already exists (idempotent)
    IF EXISTS (SELECT 1 FROM public.patients WHERE legacy_patient_code = v_code) THEN
      CONTINUE;
    END IF;

    v_user_id := gen_random_uuid();

    -- Insert into auth.users (if email not already registered)
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = v_email) THEN
      INSERT INTO auth.users (
        id, email,
        encrypted_password,
        raw_app_meta_data,
        raw_user_meta_data,
        aud, role,
        created_at, updated_at
      ) VALUES (
        v_user_id,
        v_email,
        '',
        '{"provider":"email","providers":["email"]}',
        '{}',
        'authenticated',
        'authenticated',
        now(), now()
      );
    ELSE
      SELECT id INTO v_user_id FROM auth.users WHERE email = v_email LIMIT 1;
    END IF;

    -- Insert into auth.identities
    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_email AND provider = 'email') THEN
      INSERT INTO auth.identities (
        id, user_id, provider, provider_id,
        identity_data,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_user_id,
        'email',
        v_email,
        jsonb_build_object('sub', v_user_id::text, 'email', v_email),
        now(), now()
      );
    END IF;

    -- Insert into public.patients
    INSERT INTO public.patients (
      id, auth_user_id,
      legacy_patient_code,
      first_name, last_name,
      phone, email,
      gender,
      date_of_birth,
      created_at
    ) VALUES (
      v_user_id, v_user_id,
      v_code,
      v_fname, v_lname,
      v_phone, v_email,
      v_gender::gender_type,
      v_dob,
      now()
    );

  END LOOP;
END $$;

-- Verification
SELECT
  COUNT(*)                                                         AS total_patients,
  COUNT(*) FILTER (WHERE legacy_patient_code LIKE 'PRODONT3%')    AS prodont3xx,
  COUNT(*) FILTER (WHERE legacy_patient_code LIKE 'PRODONT4%')    AS prodont4xx,
  COUNT(*) FILTER (WHERE legacy_patient_code LIKE 'PRODONT5%')    AS prodont5xx
FROM public.patients
WHERE legacy_patient_code >= 'PRODONT311'
  AND legacy_patient_code <= 'PRODONT521';
