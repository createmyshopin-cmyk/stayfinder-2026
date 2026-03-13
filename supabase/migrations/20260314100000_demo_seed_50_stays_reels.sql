-- =============================================================================
-- Demo Seed: 50 More Stays + Room Categories + Resort Stories + Reels
-- Date: 2026-03-14
-- =============================================================================

DO $$
DECLARE
  -- Stay UUIDs (s21–s70)
  s21 uuid := 'a1000021-0000-0000-0000-000000000021';
  s22 uuid := 'a1000022-0000-0000-0000-000000000022';
  s23 uuid := 'a1000023-0000-0000-0000-000000000023';
  s24 uuid := 'a1000024-0000-0000-0000-000000000024';
  s25 uuid := 'a1000025-0000-0000-0000-000000000025';
  s26 uuid := 'a1000026-0000-0000-0000-000000000026';
  s27 uuid := 'a1000027-0000-0000-0000-000000000027';
  s28 uuid := 'a1000028-0000-0000-0000-000000000028';
  s29 uuid := 'a1000029-0000-0000-0000-000000000029';
  s30 uuid := 'a1000030-0000-0000-0000-000000000030';
  s31 uuid := 'a1000031-0000-0000-0000-000000000031';
  s32 uuid := 'a1000032-0000-0000-0000-000000000032';
  s33 uuid := 'a1000033-0000-0000-0000-000000000033';
  s34 uuid := 'a1000034-0000-0000-0000-000000000034';
  s35 uuid := 'a1000035-0000-0000-0000-000000000035';
  s36 uuid := 'a1000036-0000-0000-0000-000000000036';
  s37 uuid := 'a1000037-0000-0000-0000-000000000037';
  s38 uuid := 'a1000038-0000-0000-0000-000000000038';
  s39 uuid := 'a1000039-0000-0000-0000-000000000039';
  s40 uuid := 'a1000040-0000-0000-0000-000000000040';
  s41 uuid := 'a1000041-0000-0000-0000-000000000041';
  s42 uuid := 'a1000042-0000-0000-0000-000000000042';
  s43 uuid := 'a1000043-0000-0000-0000-000000000043';
  s44 uuid := 'a1000044-0000-0000-0000-000000000044';
  s45 uuid := 'a1000045-0000-0000-0000-000000000045';
  s46 uuid := 'a1000046-0000-0000-0000-000000000046';
  s47 uuid := 'a1000047-0000-0000-0000-000000000047';
  s48 uuid := 'a1000048-0000-0000-0000-000000000048';
  s49 uuid := 'a1000049-0000-0000-0000-000000000049';
  s50 uuid := 'a1000050-0000-0000-0000-000000000050';
  s51 uuid := 'a1000051-0000-0000-0000-000000000051';
  s52 uuid := 'a1000052-0000-0000-0000-000000000052';
  s53 uuid := 'a1000053-0000-0000-0000-000000000053';
  s54 uuid := 'a1000054-0000-0000-0000-000000000054';
  s55 uuid := 'a1000055-0000-0000-0000-000000000055';
  s56 uuid := 'a1000056-0000-0000-0000-000000000056';
  s57 uuid := 'a1000057-0000-0000-0000-000000000057';
  s58 uuid := 'a1000058-0000-0000-0000-000000000058';
  s59 uuid := 'a1000059-0000-0000-0000-000000000059';
  s60 uuid := 'a1000060-0000-0000-0000-000000000060';
  s61 uuid := 'a1000061-0000-0000-0000-000000000061';
  s62 uuid := 'a1000062-0000-0000-0000-000000000062';
  s63 uuid := 'a1000063-0000-0000-0000-000000000063';
  s64 uuid := 'a1000064-0000-0000-0000-000000000064';
  s65 uuid := 'a1000065-0000-0000-0000-000000000065';
  s66 uuid := 'a1000066-0000-0000-0000-000000000066';
  s67 uuid := 'a1000067-0000-0000-0000-000000000067';
  s68 uuid := 'a1000068-0000-0000-0000-000000000068';
  s69 uuid := 'a1000069-0000-0000-0000-000000000069';
  s70 uuid := 'a1000070-0000-0000-0000-000000000070';

  -- Previous stays (for reels)
  s01 uuid := 'a1000001-0000-0000-0000-000000000001';
  s02 uuid := 'a1000002-0000-0000-0000-000000000002';
  s03 uuid := 'a1000003-0000-0000-0000-000000000003';
  s04 uuid := 'a1000004-0000-0000-0000-000000000004';
  s05 uuid := 'a1000005-0000-0000-0000-000000000005';
  s06 uuid := 'a1000006-0000-0000-0000-000000000006';
  s07 uuid := 'a1000007-0000-0000-0000-000000000007';
  s08 uuid := 'a1000008-0000-0000-0000-000000000008';
  s09 uuid := 'a1000009-0000-0000-0000-000000000009';
  s10 uuid := 'a1000010-0000-0000-0000-000000000010';
  s11 uuid := 'a1000011-0000-0000-0000-000000000011';
  s12 uuid := 'a1000012-0000-0000-0000-000000000012';
  s14 uuid := 'a1000014-0000-0000-0000-000000000014';
  s17 uuid := 'a1000017-0000-0000-0000-000000000017';
  s18 uuid := 'a1000018-0000-0000-0000-000000000018';
  s19 uuid := 'a1000019-0000-0000-0000-000000000019';
  s20 uuid := 'a1000020-0000-0000-0000-000000000020';

BEGIN

-- ============================================================
-- 50 NEW STAYS
-- ============================================================
INSERT INTO public.stays
  (id, stay_id, name, location, description, category, rating, reviews_count, price, original_price, amenities, images, status)
VALUES

-- ── COUPLE FRIENDLY (s21–s28) ──────────────────────────────

(s21,'Stay-1021','Moonlit Retreat','Coorg, Karnataka',
 'High above the coffee estates, Moonlit Retreat is a glass-walled sanctuary designed for two. A telescopic skylight brings the stars right above your bed. Wake to mist, sleep to fireflies — this is romance distilled.',
 'Couple Friendly',4.9,108,9200,13000,
 ARRAY['Free Wi-Fi','Free Breakfast','Bonfire','Mountain View','Spa','Hot Water','Garden'],
 ARRAY['https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1520250297538-29af9040b14b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80'],'active'),

(s22,'Stay-1022','The Sunset Bower','Mahabaleshwar, Maharashtra',
 'A stone cottage with a private meadow and panoramic valley views. As the sun sets over the Sahyadri ranges, sip warm chai by the firepit with the one you love. Silence is the best luxury here.',
 'Couple Friendly',4.7,83,7500,10000,
 ARRAY['Free Wi-Fi','Free Breakfast','Bonfire','Mountain View','Hot Water','Garden','Air Conditioning'],
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80'],'active'),

(s23,'Stay-1023','Romantic Cliffside','Mussoorie, Uttarakhand',
 'Perched on a cliff with unobstructed views of the Doon Valley, this boutique cottage for couples offers handcrafted breakfasts, a private forest trail, and evenings filled with the scent of pine and possibility.',
 'Couple Friendly',4.8,91,8000,11000,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water','Garden','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80'],'active'),

(s24,'Stay-1024','Garden of Eden Suite','Thekkady, Kerala',
 'Hidden inside a spice plantation, this eco-suite offers elephant sightings from the deck, boat rides on Periyar Lake, and Ayurvedic couple treatments under a certified therapist. Nature is the décor here.',
 'Couple Friendly',4.8,117,8800,12500,
 ARRAY['Free Wi-Fi','Free Breakfast','Spa','Garden','Hot Water','Mountain View'],
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1502673530728-f79b4cab31b1?auto=format&fit=crop&w=800&q=80'],'active'),

(s25,'Stay-1025','The Ivory Cottage','Ooty, Tamil Nadu',
 'A century-old planter''s cottage with lovingly restored teak floors, clawfoot baths, and a wisteria-draped veranda. Three eucalyptus-scented acres, zero phone signal, and everything you need for a perfect reset.',
 'Couple Friendly',4.7,72,7000,9500,
 ARRAY['Free Wi-Fi','Free Breakfast','Garden','Spa','Hot Water','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80'],'active'),

(s26,'Stay-1026','Stargazer''s Hideout','Spiti Valley, Himachal Pradesh',
 'At 12,500 ft above sea level, light pollution doesn''t exist. Thick yak-wool duvets, a panoramic glass ceiling, and a dedicated stargazing deck make this remote mud-brick retreat an astronomers'' and romantics'' dream.',
 'Couple Friendly',4.9,54,11500,16000,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80'],'active'),

(s27,'Stay-1027','Blushing Rose Villa','Kodaikanal, Tamil Nadu',
 'A rose-garden estate in the cloud city of Kodaikanal. The villa has a private boat on Kodai Lake, a breakfast conservatory filled with orchids, and a jacuzzi overlooking pine-wrapped hillsides.',
 'Couple Friendly',4.8,96,8500,12000,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Breakfast','Spa','Garden','Hot Water','Mountain View'],
 ARRAY['https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1520637836993-a0e5b1a2f7a8?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80'],'active'),

(s28,'Stay-1028','Honeymoon Treetop','Vythiri, Wayanad',
 'The highest treehouse in Wayanad, built for couples only. A private rope-bridge entrance, an open-air rain shower, and a jungle telescope for wildlife spotting. Breakfast arrives via a hand-woven basket pulley.',
 'Couple Friendly',4.9,144,10000,14000,
 ARRAY['Free Wi-Fi','Free Breakfast','Garden','Mountain View','Hot Water','Bonfire','Spa'],
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80'],'active'),

-- ── FAMILY STAY (s29–s36) ──────────────────────────────────

(s29,'Stay-1029','Jungle Jamboree Resort','Bandipur, Karnataka',
 'Safari, zipline, bonfire, wildlife walks, and a natural pool — Jungle Jamboree packs every family adventure into one sprawling forest property on the Bandipur buffer zone. Kids under 6 stay free.',
 'Family Stay',4.6,198,6500,8500,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Breakfast','Free Parking','Kid Friendly','Bonfire','Garden','Camping'],
 ARRAY['https://images.unsplash.com/photo-1533104816931-20fa691ff6ca?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1484910292437-025e5d13ce87?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1502673530728-f79b4cab31b1?auto=format&fit=crop&w=800&q=80'],'active'),

(s30,'Stay-1030','Meadow Bliss Family Stay','Kasol, Himachal Pradesh',
 'A cluster of wooden chalets beside the Parvati River in the Kullu Valley. Children''s treasure hunt trails, river-dipping, and forest yoga in the morning make this the perfect high-altitude family break.',
 'Family Stay',4.5,162,4500,6000,
 ARRAY['Free Wi-Fi','Free Breakfast','Free Parking','Kid Friendly','Garden','Mountain View','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1517490232338-06b912a786b5?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80'],'active'),

(s31,'Stay-1031','Plantation Heritage Home','Coorg, Karnataka',
 'A 150-year-old estate bungalow in the middle of a working coffee and pepper plantation. Coffee-picking tours, homemade Coorgi meals, and a river for the kids to splash in all day. Generations of warmth.',
 'Family Stay',4.7,143,8000,11000,
 ARRAY['Free Wi-Fi','Free Breakfast','Free Parking','Kid Friendly','Garden','Restaurant','Hot Water'],
 ARRAY['https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1509233725247-49e657c54213?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1505843513577-22bb7d21e455?auto=format&fit=crop&w=800&q=80'],'active'),

(s32,'Stay-1032','Lakeview Family Retreat','Nainital, Uttarakhand',
 'A multi-room lake-facing bungalow with a private boating jetty on Naini Lake. Cycle rentals, the zoo, and Snow View Point are all within walking distance. Cosy fireplace evenings complete the picture.',
 'Family Stay',4.6,177,7200,9800,
 ARRAY['Free Wi-Fi','Free Breakfast','Free Parking','Kid Friendly','Mountain View','Hot Water','Garden'],
 ARRAY['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80'],'active'),

(s33,'Stay-1033','Savannah Safari Resort','Ranthambore, Rajasthan',
 'Sit on your private deck and watch nilgai graze at dawn. Ranthambore''s finest family jungle camp. Jeep safaris, nature trails, and the kids'' craft corner make every hour count on this wildlife odyssey.',
 'Family Stay',4.7,129,9500,13000,
 ARRAY['Free Wi-Fi','Swimming Pool','Restaurant','Free Breakfast','Free Parking','Kid Friendly','Air Conditioning','TV'],
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80'],'active'),

(s34,'Stay-1034','Hill Country Family Estate','Ooty, Tamil Nadu',
 'A nine-bedroom estate atop the Nilgiri plateau — big enough for the whole extended family. Vegetable garden the kids can harvest, a badminton lawn, a billiards room, and a legendary cook who makes Ootacamund curry.',
 'Family Stay',4.6,88,12000,16000,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Breakfast','Free Parking','Kid Friendly','Garden','Hot Water','TV'],
 ARRAY['https://images.unsplash.com/photo-1520637836993-a0e5b1a2f7a8?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80'],'active'),

(s35,'Stay-1035','Riverside Camping Resort','Rishikesh, Uttarakhand',
 'Glamping tents on the Ganga banks with proper beds, ensuite bathrooms, and a communal bonfire. By day: white-water rafting, cliff jumping, and zip-lining. By night: riverside dinner under stars. Adventure for all ages.',
 'Family Stay',4.5,224,3800,5500,
 ARRAY['Free Wi-Fi','Free Breakfast','Bonfire','Mountain View','Camping','Kid Friendly','Pet Friendly'],
 ARRAY['https://images.unsplash.com/photo-1500259571355-332da5cb07aa?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1483653364400-eedcfb9f1f88?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?auto=format&fit=crop&w=800&q=80'],'active'),

(s36,'Stay-1036','Mountain Family Lodge','Manali, Himachal Pradesh',
 'Cosy cedar-log lodge with six family rooms, a sledding slope in winter, river fishing in summer, and a home bakery that perfumes the whole valley. Snow, river, and mountains — all from the same window.',
 'Family Stay',4.7,166,5800,8000,
 ARRAY['Free Wi-Fi','Free Breakfast','Free Parking','Kid Friendly','Mountain View','Hot Water','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80'],'active'),

-- ── LUXURY RESORT (s37–s44) ────────────────────────────────

(s37,'Stay-1037','The Maharaja Palace','Jaisalmer, Rajasthan',
 'Sleep inside a real sandstone haveli in the Golden City. Rooftop dining over the glowing fort, camel polo on the dunes, a Marwari-fusion tasting menu, and 18th-century rooms with modern four-poster beds.',
 'Luxury Resort',5.0,287,32000,45000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Gym','Free Parking'],
 ARRAY['https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80'],'active'),

(s38,'Stay-1038','Golden Sands Beach Resort','Gokarna, Karnataka',
 'A private beach hideaway between Om Beach and Half Moon Beach. Tented beach suites, a zero-entry infinity pool that meets the sea, fresh-catch meals, and a sunset yacht charter. Barefoot luxury, perfected.',
 'Luxury Resort',4.9,198,26000,36000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Gym'],
 ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1540541338537-c8bfbbd7df5b?auto=format&fit=crop&w=800&q=80'],'active'),

(s39,'Stay-1039','Kempegowda Luxury Lodge','Coorg, Karnataka',
 'Carved teak and polished laterite stone define this award-winning eco-luxury resort spread over 40 coffee-estate acres. A 400 sq ft spa cabin, a spring-water pool, and private plantation walks — wilderness meets refinement.',
 'Luxury Resort',4.9,224,21000,29000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','Hot Water','Gym','Free Parking'],
 ARRAY['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=800&q=80'],'active'),

(s40,'Stay-1040','Royal Haveli Heritage','Jodhpur, Rajasthan',
 'A blue-city palace with hand-painted frescoes, a rooftop mehfil stage, and a 16th-century zenana turned luxury suite. The chef recreates 300-year-old royal recipes; the butler arranges private fort tours at twilight.',
 'Luxury Resort',5.0,312,35000,48000,
 ARRAY['Free Wi-Fi','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Free Parking','Gym','Swimming Pool'],
 ARRAY['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80'],'active'),

(s41,'Stay-1041','The Sky Lounge Resort','Mussoorie, Uttarakhand',
 'Mussoorie''s most-talked-about luxury resort sits above the clouds at 7,200 ft. Glass-floor sky villa, helicopter pad, 180° Himalayan panorama, and a six-course degustation menu make this a bucket-list address.',
 'Luxury Resort',4.9,167,29000,40000,
 ARRAY['Free Wi-Fi','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Gym','Mountain View'],
 ARRAY['https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80'],'active'),

(s42,'Stay-1042','Malabar Luxury Estate','Kozhikode, Kerala',
 'A colonial spice-trading mansion turned luxury heritage estate on the Malabar Coast. Pepper ceilings, Chinese fishing-net views, a Kalaripayattu performance, and a curated Moplah cuisine dinner for guests.',
 'Luxury Resort',4.8,144,19500,27000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water'],
 ARRAY['https://images.unsplash.com/photo-1586375300773-8384e3e4916f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80'],'active'),

(s43,'Stay-1043','Himalayan Crown Resort','Uttarkashi, Uttarakhand',
 'At the foot of the Gangotri glacier, this luxury wilderness camp blends reverence with opulence. Crystal-clear Bhagirathi river bath, private puja ceremony at dawn, Garhwali home-cooked meals, and the silence of the high Himalayas.',
 'Luxury Resort',4.9,112,27000,38000,
 ARRAY['Free Wi-Fi','Free Breakfast','Spa','Hot Water','Mountain View','Bonfire','Restaurant'],
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80'],'active'),

(s44,'Stay-1044','The Jade Island Resort','Lakshadweep',
 'Only accessible by seaplane, Jade Island is India''s most exclusive atoll retreat. Glass-bottom overwater bungalows, bioluminescent lagoon kayaking, private reef snorkelling, and a no-phone policy that sets you free.',
 'Luxury Resort',5.0,98,55000,75000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Gym'],
 ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=800&q=80'],'active'),

-- ── BUDGET ROOMS (s45–s52) ─────────────────────────────────

(s45,'Stay-1045','The Wanderer''s Inn','Hampi, Karnataka',
 'Mud-and-bamboo rooms inside a restored historic hamlet. Rent a bicycle, explore the boulder landscape, and return for a wood-fired breakfast and a rooftop sunset that''s entirely free. Hampi for the smart traveller.',
 'Budget Rooms',4.3,284,1200,2000,
 ARRAY['Free Wi-Fi','Free Breakfast','Hot Water','Mountain View'],
 ARRAY['https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?auto=format&fit=crop&w=800&q=80'],'active'),

(s46,'Stay-1046','Om Shanti Hostel','Varanasi, Uttar Pradesh',
 'Riverfront budget stay 50 metres from the Dashashwamedh Ghat. Book a sunrise boat, a cooking class, and a silk-weaver visit — all arranged by the guesthouse. The Ganga at dawn will change you.',
 'Budget Rooms',4.2,318,900,1600,
 ARRAY['Free Wi-Fi','Hot Water','Free Breakfast'],
 ARRAY['https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80'],'active'),

(s47,'Stay-1047','Desert Nomad Beds','Jaisalmer, Rajasthan',
 'Camp-style rooms inside Jaisalmer''s old city with traditional block-printed furnishings, rooftop chai sessions, and a resident guide who takes you through the living fort''s maze of temples and havelis.',
 'Budget Rooms',4.4,247,1100,1900,
 ARRAY['Free Wi-Fi','Free Breakfast','Hot Water','TV'],
 ARRAY['https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80'],'active'),

(s48,'Stay-1048','City Backpack House','Bandra, Mumbai',
 'A curated urban hostel in Bandra West. Walkable to Bandstand, Elco market, and Carter Road. Capsule-style beds, strong coffee, a co-working corner, and a community breakfast make this a home-away-from-home.',
 'Budget Rooms',4.3,399,1300,2100,
 ARRAY['Free Wi-Fi','Hot Water','Air Conditioning','Free Breakfast','TV'],
 ARRAY['https://images.unsplash.com/photo-1414369153946-7d64ca7d7af1?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80'],'active'),

(s49,'Stay-1049','Mountain Bunk House','Dharamshala, Himachal Pradesh',
 'Steps from the Tibetan monastery in Upper Dharamshala, this cosy bunk house doubles as a meditation and trekking base. A Tibetan chef cooks the best thukpa in town; the views of Dhauladhar will outlast your holiday.',
 'Budget Rooms',4.4,276,1050,1700,
 ARRAY['Free Wi-Fi','Hot Water','Free Breakfast','Mountain View'],
 ARRAY['https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80'],'active'),

(s50,'Stay-1050','Coastal Crash Pad','Puri, Odisha',
 'A no-fuss beach shack steps from Puri''s Golden Beach. Pack light, eat fresh-catch bhunja, watch Rath Yatra from the roof, and sleep to the rhythm of waves. Budget beach bliss.',
 'Budget Rooms',4.1,203,850,1400,
 ARRAY['Free Wi-Fi','Hot Water','Fan'],
 ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1500259571355-332da5cb07aa?auto=format&fit=crop&w=800&q=80'],'active'),

(s51,'Stay-1051','Forest Rest House','Kaziranga, Assam',
 'A classic government-turned-private forest rest house on the Kaziranga perimeter. Jeep safari at dawn, elephant safari at dusk, and a full-board meal of traditional Assamese thali. Wild India, affordable.',
 'Budget Rooms',4.3,189,2200,3200,
 ARRAY['Free Wi-Fi','Free Breakfast','Hot Water','Free Parking'],
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80'],'active'),

(s52,'Stay-1052','Valley Budget Stay','Spiti, Himachal Pradesh',
 'A monk-run guesthouse in a white-washed stone village at 12,000 ft. Communal meals, prayer-wheel mornings, and sweeping Spiti Valley vistas included in the tariff. The most peaceful ₹1,500 you''ll ever spend.',
 'Budget Rooms',4.5,142,1500,2400,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water'],
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80'],'active'),

-- ── POOL VILLAS (s53–s61) ──────────────────────────────────

(s53,'Stay-1053','Palm Grove Pool Villa','South Goa',
 'A four-bedroom Portuguese-era villa behind Palolem with a 25 m private pool, cook-on-call, and a resident butler. Surrounded by palms, scented by frangipani, just a golf-cart ride from the beach.',
 'Pool Villas',4.9,213,19500,27000,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Parking','Air Conditioning','TV','Hot Water','Restaurant','Spa'],
 ARRAY['https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=800&q=80'],'active'),

(s54,'Stay-1054','The Oasis Villa','Udaipur, Rajasthan',
 'A white-marble villa with an infinity pool overlooking the Aravalli hills. Rajasthani frescoes, a subterranean wine cellar, and a boat-ride breakfast on the lake are among the many privileges here.',
 'Pool Villas',4.9,176,22000,30000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Free Parking'],
 ARRAY['https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80'],'active'),

(s55,'Stay-1055','Infinity Heights Villa','Kasauli, Himachal Pradesh',
 'A contemporary mountain villa with a heated outdoor infinity pool cantilevered over the valley floor. Five bedrooms, an observatory deck, and a chef who sources herbs from the terrace garden daily.',
 'Pool Villas',4.8,134,17000,23000,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Parking','Air Conditioning','Hot Water','Mountain View','Garden','Free Breakfast'],
 ARRAY['https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80'],'active'),

(s56,'Stay-1056','Monsoon Manor','Lonavala, Maharashtra',
 'During monsoon, the pool overflows with rainwater and the valley turns a blinding emerald. This five-bedroom manor is designed for the rains — open-sided pavilions, waterfall access, and mist-walk trails.',
 'Pool Villas',4.7,158,14500,20000,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Parking','Air Conditioning','TV','Hot Water','Garden','Free Breakfast'],
 ARRAY['https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1510525009256-d4926e8c820f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80'],'active'),

(s57,'Stay-1057','Tropical Pool Retreat','Alleppey, Kerala',
 'A houseboat-inspired villa on the backwaters with a lagoon-fed pool, private canoe, and a chef who does live toddy-tapping. Fall asleep to frogs, wake to kingfishers. Alleppey''s best-kept secret.',
 'Pool Villas',4.8,189,15500,21000,
 ARRAY['Free Wi-Fi','Swimming Pool','Restaurant','Free Breakfast','Hot Water','Air Conditioning','TV','Garden'],
 ARRAY['https://images.unsplash.com/photo-1586375300773-8384e3e4916f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80'],'active'),

(s58,'Stay-1058','Desert Pool Palace','Jodhpur, Rajasthan',
 'The only villa in Rajasthan with a blue-tiled desert infinity pool overlooking the Mehrangarh Fort. Camel rides, kite-flying evenings, and puppet shows by the pool — a royal desert dream.',
 'Pool Villas',4.9,144,21000,29000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Restaurant','Free Breakfast','Air Conditioning','TV','Hot Water','Free Parking'],
 ARRAY['https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80'],'active'),

(s59,'Stay-1059','The Secret Garden Villa','Coorg, Karnataka',
 'Hidden behind a bamboo gate on a 6-acre estate, this three-bedroom villa has a natural plunge pool fed by a hill spring. Jungle yoga at dawn, coffee picking at noon, and a star-lit deck at night.',
 'Pool Villas',4.8,121,16000,22000,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Parking','Garden','Free Breakfast','Hot Water','Spa','Mountain View'],
 ARRAY['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1520250297538-29af9040b14b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=800&q=80'],'active'),

(s60,'Stay-1060','Sunset Mesa Villa','Hampi, Karnataka',
 'The most dramatic villa in Hampi — a natural boulder landscape surrounds the private pool and sundeck. Explore the UNESCO ruins by day, float in your infinity pool at golden hour, and cook starlit dinners together.',
 'Pool Villas',4.8,97,13500,18500,
 ARRAY['Free Wi-Fi','Swimming Pool','Free Parking','Air Conditioning','Hot Water','Mountain View','Garden'],
 ARRAY['https://images.unsplash.com/photo-1510525009256-d4926e8c820f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1540541338537-c8bfbbd7df5b?auto=format&fit=crop&w=800&q=80'],'active'),

(s61,'Stay-1061','Silver Cascade Villa','Munnar, Kerala',
 'Perched above the Attukal waterfall, Silver Cascade has a mist-fed rock pool that fills naturally every morning. Tea-estate wraparound and a private waterfall path mean you''ll never want to leave the property.',
 'Pool Villas',4.9,163,17500,24000,
 ARRAY['Free Wi-Fi','Swimming Pool','Spa','Free Breakfast','Hot Water','Mountain View','Garden','Air Conditioning'],
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80'],'active'),

-- ── TREE HOUSES (s62–s68) ──────────────────────────────────

(s62,'Stay-1062','The Eagle''s Nest','Coorg, Karnataka',
 'Built 50 ft up in a single giant jackfruit tree, Eagle''s Nest is Coorg''s most photographed treehouse. Spiral staircase entrance, an open-air shower, and an eagle''s view over the cardamom valley below.',
 'Tree Houses',4.9,178,9500,14000,
 ARRAY['Free Wi-Fi','Free Breakfast','Hot Water','Mountain View','Garden'],
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80'],'active'),

(s63,'Stay-1063','Banyan Crown Treehouse','Ooty, Tamil Nadu',
 'A cluster of three interconnected rooms in an ancient banyan with an 80-ft canopy. The hammock lounge, rope swings, and bird-watching platform make this a treehouse that even grown-ups won''t want to leave.',
 'Tree Houses',4.8,122,8000,11500,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Garden','Hot Water'],
 ARRAY['https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80'],'active'),

(s64,'Stay-1064','Misty Heights Treehouse','Cherrapunji, Meghalaya',
 'Floating in the mist at the wettest place on Earth. A glass-panelled treehouse surrounded by living root bridges, the widest waterfalls in Asia, and a breakfast of traditional Khasi rice dishes. Surreal and unforgettable.',
 'Tree Houses',4.9,87,10500,15000,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water','Garden'],
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80'],'active'),

(s65,'Stay-1065','River Oak Treehouse','Jim Corbett, Uttarakhand',
 'Built around a 200-year-old Sal tree on the Ramganga riverbank. The machan-style deck is a prime spot for spotting leopards at dusk. Solar-powered, hand-crafted, and entirely off-grid.',
 'Tree Houses',4.8,104,8500,12500,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water','Garden','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80'],'active'),

(s66,'Stay-1066','Canopy Dreams','Vythiri, Wayanad',
 'A double-storey treehouse for families and groups of up to six, connected by a covered sky bridge to a smaller treehouse. Separate bathrooms on each level, a campfire circle below, and tea at dawn 30 ft up.',
 'Tree Houses',4.7,136,9000,13000,
 ARRAY['Free Wi-Fi','Free Breakfast','Garden','Mountain View','Hot Water','Bonfire','Pet Friendly'],
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1502673530728-f79b4cab31b1?auto=format&fit=crop&w=800&q=80'],'active'),

(s67,'Stay-1067','Rainforest Loft','Agumbe, Karnataka',
 'Agumbe receives the second-highest rainfall in India and this treehouse celebrates every drop. Bamboo walls, a moss roof, and frog-song lullabies. The resident naturalist leads candlelit night-safari walks through the shola forest.',
 'Tree Houses',4.7,78,7500,11000,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Garden','Hot Water'],
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80'],'active'),

(s68,'Stay-1068','Sky Roots Treehouse','Araku Valley, Andhra Pradesh',
 'Perched 40 ft above Araku''s coffee estates, Sky Roots offers tribal-art-adorned rooms, a sunrise coffee ritual, waterfall hikes, and bison watching from the deck. Andhra''s most unique stay, hands down.',
 'Tree Houses',4.8,93,8000,12000,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Garden','Hot Water','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80'],'active'),

-- ── NON AC ROOMS (s69–s70) ─────────────────────────────────

(s69,'Stay-1069','Breezy Hilltop Stay','Munnar, Kerala',
 'Simple, breezy rooms at 5,000 ft — naturally cool year-round, no AC ever needed. A verandah full of flowering plants, a rooftop with 360° tea-estate views, and home-cooked Kerala meals twice a day.',
 'Non AC Rooms',4.4,237,1900,2800,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water','Garden'],
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80'],'active'),

(s70,'Stay-1070','Cool Mountain Retreat','Kodaikanal, Tamil Nadu',
 'At 7,200 ft, a fan is a luxury item you''ll never use. This non-AC heritage homestay has fireplaces in every room, cosy hand-stitched quilts, and the best-value multi-course breakfast in the Palani Hills.',
 'Non AC Rooms',4.5,188,2100,3200,
 ARRAY['Free Wi-Fi','Free Breakfast','Mountain View','Hot Water','Garden','Bonfire'],
 ARRAY['https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80',
       'https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80'],'active')

ON CONFLICT (stay_id) DO NOTHING;


-- ============================================================
-- ROOM CATEGORIES FOR NEW STAYS
-- ============================================================
INSERT INTO public.room_categories
  (stay_id, name, max_guests, available, amenities, price, original_price, images)
VALUES
-- s21
(s21,'Glass Sky Suite',2,1,ARRAY['King Bed','Telescopic Skylight','Private Deck','Rainfall Shower'],9200,13000,
 ARRAY['https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=800&q=80']),
(s21,'Mist View Room',2,3,ARRAY['Queen Bed','Valley View','En-suite','Fireplace'],6500,9000,
 ARRAY['https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80']),

-- s22
(s22,'Meadow Cottage',2,2,ARRAY['King Bed','Meadow View','Fireplace','Kitchenette'],7500,10000,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),
(s22,'Garden Nook',2,3,ARRAY['Double Bed','Garden View','En-suite'],5000,7000,
 ARRAY['https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80']),

-- s23
(s23,'Cliff Suite',2,2,ARRAY['King Bed','Valley View','Outdoor Shower','Private Deck'],8000,11000,
 ARRAY['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80']),
(s23,'Pine Cabin',2,3,ARRAY['Double Bed','Forest View','En-suite','Wood Stove'],5500,7500,
 ARRAY['https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80']),

-- s24
(s24,'Spice Suite',2,2,ARRAY['King Bed','Plantation View','Spa Access','En-suite'],8800,12500,
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80']),
(s24,'Lake View Room',2,3,ARRAY['Queen Bed','Lake View','En-suite','Balcony'],6000,8500,
 ARRAY['https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80']),

-- s25
(s25,'Heritage Master Suite',2,1,ARRAY['Four-Poster Bed','Clawfoot Tub','Veranda','Butler'],7000,9500,
 ARRAY['https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80']),
(s25,'Garden Room',2,4,ARRAY['Double Bed','Garden View','En-suite'],4800,6500,
 ARRAY['https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80']),

-- s26
(s26,'Stargazer Loft',2,1,ARRAY['King Bed','Glass Ceiling','Stargazing Deck','Yak Wool Duvets'],11500,16000,
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80']),
(s26,'Mud Brick Hideout',2,3,ARRAY['Twin Beds','Mountain View','Shared Bathroom'],7000,10000,
 ARRAY['https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80']),

-- s27
(s27,'Rose Garden Suite',2,2,ARRAY['King Bed','Private Jacuzzi','Lake View','Butler'],8500,12000,
 ARRAY['https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=800&q=80']),
(s27,'Orchid Room',2,3,ARRAY['Queen Bed','Garden View','En-suite'],6000,8500,
 ARRAY['https://images.unsplash.com/photo-1520637836993-a0e5b1a2f7a8?auto=format&fit=crop&w=800&q=80']),

-- s28
(s28,'Honeymoon Canopy Suite',2,1,ARRAY['King Bed','Rope Bridge Entry','Rain Shower','Sky Deck'],10000,14000,
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80']),
(s28,'Jungle Loft',2,2,ARRAY['Double Bed','Forest View','Shared Bathroom','Hammock'],6500,9000,
 ARRAY['https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80']),

-- s29
(s29,'Safari Cottage',4,4,ARRAY['2 Beds','Jungle View','En-suite','Porch'],6500,8500,
 ARRAY['https://images.unsplash.com/photo-1533104816931-20fa691ff6ca?auto=format&fit=crop&w=800&q=80']),
(s29,'Family Tent',6,3,ARRAY['Bunk Beds','Living Area','Shared Bath','Campfire'],4200,5800,
 ARRAY['https://images.unsplash.com/photo-1484910292437-025e5d13ce87?auto=format&fit=crop&w=800&q=80']),

-- s30
(s30,'River Chalet',4,3,ARRAY['2 Rooms','River View','En-suite','Deck'],4500,6000,
 ARRAY['https://images.unsplash.com/photo-1517490232338-06b912a786b5?auto=format&fit=crop&w=800&q=80']),
(s30,'Valley Dorm',6,2,ARRAY['Bunk Beds','Mountain View','Shared Bath','Lockers'],2000,3000,
 ARRAY['https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=80']),

-- s31
(s31,'Planter''s Suite',2,1,ARRAY['King Bed','Plantation View','Veranda','Butler'],8000,11000,
 ARRAY['https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=800&q=80']),
(s31,'Estate Room',4,4,ARRAY['2 Queen Beds','Garden View','En-suite'],5500,7500,
 ARRAY['https://images.unsplash.com/photo-1509233725247-49e657c54213?auto=format&fit=crop&w=800&q=80']),

-- s32
(s32,'Lake Suite',4,2,ARRAY['2 Beds','Lake View','En-suite','Fireplace','Balcony'],7200,9800,
 ARRAY['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80']),
(s32,'Hill View Room',2,5,ARRAY['Queen Bed','Mountain View','En-suite'],5000,6800,
 ARRAY['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80']),

-- s33
(s33,'Jungle Safari Tent',2,6,ARRAY['King Bed','Wildlife View','En-suite Bathroom','Private Deck','Minibar'],9500,13000,
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80']),
(s33,'Family Suite',4,3,ARRAY['2 Bedrooms','Living Room','Pool View','Butler'],13000,18000,
 ARRAY['https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80']),

-- s34
(s34,'Master Nilgiri Suite',2,1,ARRAY['King Bed','360° View','Clawfoot Tub','Butler'],12000,16000,
 ARRAY['https://images.unsplash.com/photo-1520637836993-a0e5b1a2f7a8?auto=format&fit=crop&w=800&q=80']),
(s34,'Family Bungalow Room',4,6,ARRAY['2 Beds','Garden View','En-suite'],7500,10000,
 ARRAY['https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80']),

-- s35
(s35,'Glamping Tent',2,8,ARRAY['King Bed','River View','Ensuite','Deck'],3800,5500,
 ARRAY['https://images.unsplash.com/photo-1500259571355-332da5cb07aa?auto=format&fit=crop&w=800&q=80']),
(s35,'Family Tent',4,4,ARRAY['2 Beds','Shared Bathroom','Hammock','Fan'],2500,3800,
 ARRAY['https://images.unsplash.com/photo-1483653364400-eedcfb9f1f88?auto=format&fit=crop&w=800&q=80']),

-- s36
(s36,'Mountain Suite',4,3,ARRAY['2 Beds','Mountain View','Fireplace','En-suite'],5800,8000,
 ARRAY['https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=800&q=80']),
(s36,'Cedar Cabin',2,4,ARRAY['Queen Bed','Snow View','En-suite','Wood Stove'],4200,5800,
 ARRAY['https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80']),

-- s37
(s37,'Royal Dune Suite',2,3,ARRAY['King Bed','Fort View','Jacuzzi','Butler','Mini Bar'],32000,45000,
 ARRAY['https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80']),
(s37,'Heritage Haveli Room',2,8,ARRAY['Queen Bed','Courtyard View','En-suite','Period Decor'],20000,28000,
 ARRAY['https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?auto=format&fit=crop&w=800&q=80']),
(s37,'Sand Palace Suite',4,4,ARRAY['2 Bedrooms','Rooftop Terrace','Private Pool','Butler','Champagne'],45000,62000,
 ARRAY['https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80']),

-- s38
(s38,'Beach Tented Suite',2,5,ARRAY['King Bed','Private Beach','Ocean View','Outdoor Shower','Kayak'],26000,36000,
 ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80']),
(s38,'Sea Villa',4,3,ARRAY['2 Bedrooms','Pool Access','Private Beach','Deck'],36000,50000,
 ARRAY['https://images.unsplash.com/photo-1473116763249-2faaef81ccda?auto=format&fit=crop&w=800&q=80']),

-- s39
(s39,'Plantation Eco-Suite',2,4,ARRAY['King Bed','Coffee Garden View','Spring Pool Access','En-suite'],21000,29000,
 ARRAY['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80']),
(s39,'Canopy Cottage',2,6,ARRAY['Queen Bed','Jungle View','Shared Pool','Veranda'],15000,20000,
 ARRAY['https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80']),

-- s40
(s40,'Zenana Royal Suite',2,3,ARRAY['King Bed','Fort View','Private Pool','Butler','Frescoes'],35000,48000,
 ARRAY['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80']),
(s40,'Courtyard Heritage Room',2,10,ARRAY['Queen Bed','Courtyard View','En-suite','Rajasthani Antiques'],22000,30000,
 ARRAY['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80']),

-- s41
(s41,'Sky Villa',2,3,ARRAY['King Bed','Glass Floor','360° Himalaya View','Private Terrace','Butler'],29000,40000,
 ARRAY['https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=800&q=80']),
(s41,'Cloud Room',2,7,ARRAY['Queen Bed','Valley View','En-suite','Balcony'],18000,24000,
 ARRAY['https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80']),

-- s42
(s42,'Colonial Sea Suite',2,4,ARRAY['King Bed','Sea View','Claw Tub','Butler'],19500,27000,
 ARRAY['https://images.unsplash.com/photo-1586375300773-8384e3e4916f?auto=format&fit=crop&w=800&q=80']),
(s42,'Spice Room',2,6,ARRAY['Queen Bed','Garden View','En-suite','Period Furniture'],13000,18000,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),

-- s43
(s43,'Glacier View Suite',2,4,ARRAY['King Bed','Glacier View','Private Puja Deck','En-suite'],27000,38000,
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80']),
(s43,'River Camp Tent',2,6,ARRAY['Double Bed','River View','En-suite Bathroom','Heated Blankets'],18000,25000,
 ARRAY['https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80']),

-- s44
(s44,'Overwater Glass Bungalow',2,6,ARRAY['King Bed','Glass Floor','Direct Lagoon Access','Snorkel Gear'],55000,75000,
 ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80']),
(s44,'Beach Villa',4,2,ARRAY['2 Bedrooms','Private Island Access','Pool','Butler'],75000,100000,
 ARRAY['https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=800&q=80']),

-- s45–s52 budget
(s45,'Budget Double Room',2,5,ARRAY['Double Bed','Fan','Shared Bathroom','Mountain View'],1200,2000,
 ARRAY['https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80']),
(s46,'Ghat View Room',2,4,ARRAY['Double Bed','Ganga View','Fan','Shared Bathroom'],900,1600,
 ARRAY['https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80']),
(s47,'Fort View Room',2,4,ARRAY['Double Bed','Fort View','Fan','Shared Bathroom'],1100,1900,
 ARRAY['https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80']),
(s48,'Capsule Pod',1,10,ARRAY['Single Bed','Capsule Curtain','Shared Bathroom','Locker','AC'],1300,2100,
 ARRAY['https://images.unsplash.com/photo-1414369153946-7d64ca7d7af1?auto=format&fit=crop&w=800&q=80']),
(s49,'Monastery View Dorm',4,3,ARRAY['Bunk Beds','Mountain View','Shared Bathroom','Fan'],1050,1700,
 ARRAY['https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80']),
(s50,'Beach Shack Room',2,6,ARRAY['Double Bed','Beach Access','Fan','Shared Bathroom'],850,1400,
 ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80']),
(s51,'Forest Room',2,4,ARRAY['Double Bed','Jungle View','En-suite','Fan'],2200,3200,
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80']),
(s52,'Valley Guest Room',2,5,ARRAY['Double Bed','Valley View','Shared Bathroom','Fan'],1500,2400,
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80']),

-- s53
(s53,'Master Pool Suite',2,1,ARRAY['King Bed','Private Pool','Sea View','Butler','Outdoor Shower'],19500,27000,
 ARRAY['https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=800&q=80']),
(s53,'Palm Villa Room',4,3,ARRAY['2 Beds','Pool Access','Garden View','En-suite'],14000,19000,
 ARRAY['https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=800&q=80']),

-- s54
(s54,'Marble Lake Suite',2,2,ARRAY['King Bed','Infinity Pool','Lake View','Butler','Jacuzzi'],22000,30000,
 ARRAY['https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80']),
(s54,'Haveli Pool Room',2,5,ARRAY['Queen Bed','Pool Access','Courtyard View','En-suite'],15000,20000,
 ARRAY['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80']),

-- s55
(s55,'Cantilevered Pool Suite',2,2,ARRAY['King Bed','Heated Pool','Valley View','Outdoor Shower'],17000,23000,
 ARRAY['https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=800&q=80']),
(s55,'Mountain Garden Room',2,4,ARRAY['Queen Bed','Garden View','Pool Access','En-suite'],11000,15000,
 ARRAY['https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80']),

-- s56
(s56,'Monsoon Pool Suite',2,2,ARRAY['King Bed','Rainwater Pool','Waterfall View','Deck'],14500,20000,
 ARRAY['https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80']),
(s56,'Valley Room',2,4,ARRAY['Queen Bed','Valley View','Pool Access','En-suite'],9500,13000,
 ARRAY['https://images.unsplash.com/photo-1510525009256-d4926e8c820f?auto=format&fit=crop&w=800&q=80']),

-- s57
(s57,'Backwater Villa',2,2,ARRAY['King Bed','Lagoon Pool','Private Canoe','Outdoor Shower'],15500,21000,
 ARRAY['https://images.unsplash.com/photo-1586375300773-8384e3e4916f?auto=format&fit=crop&w=800&q=80']),
(s57,'Houseboat Studio',2,4,ARRAY['Queen Bed','Backwater View','Pool Access','En-suite'],10000,14000,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),

-- s58
(s58,'Fort View Pool Suite',2,2,ARRAY['King Bed','Fort View','Infinity Pool','Butler'],21000,29000,
 ARRAY['https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80']),
(s58,'Desert Haveli Room',2,5,ARRAY['Queen Bed','Courtyard View','Pool Access','AC'],14000,19000,
 ARRAY['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80']),

-- s59
(s59,'Garden Plunge Suite',2,2,ARRAY['King Bed','Spring Pool','Garden View','Outdoor Shower'],16000,22000,
 ARRAY['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80']),
(s59,'Coffee Estate Room',2,4,ARRAY['Queen Bed','Plantation View','Pool Access','En-suite'],10500,14500,
 ARRAY['https://images.unsplash.com/photo-1520250297538-29af9040b14b?auto=format&fit=crop&w=800&q=80']),

-- s60
(s60,'Boulder Pool Suite',2,2,ARRAY['King Bed','Rock Landscape','Infinity Pool','Outdoor Deck'],13500,18500,
 ARRAY['https://images.unsplash.com/photo-1510525009256-d4926e8c820f?auto=format&fit=crop&w=800&q=80']),
(s60,'Mesa Studio',2,4,ARRAY['Queen Bed','Valley View','Pool Access','En-suite'],8500,12000,
 ARRAY['https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80']),

-- s61
(s61,'Waterfall Pool Suite',2,2,ARRAY['King Bed','Rock Pool','Waterfall View','Open Bath'],17500,24000,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),
(s61,'Tea Estate Room',2,4,ARRAY['Queen Bed','Tea Garden View','Pool Access','En-suite'],12000,16500,
 ARRAY['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80']),

-- s62–s68 treehouses
(s62,'Eagle''s Canopy Suite',2,1,ARRAY['King Bed','Spiral Staircase','Open Air Shower','Eagle View'],9500,14000,
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80']),
(s62,'Nest Room',2,2,ARRAY['Double Bed','Canopy View','En-suite','Hammock'],6000,9000,
 ARRAY['https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80']),

(s63,'Banyan Crown Room',4,2,ARRAY['2 Beds','Canopy View','En-suite','Hammock Lounge'],8000,11500,
 ARRAY['https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80']),
(s63,'Bird Perch Room',2,3,ARRAY['Double Bed','Forest View','Shared Bathroom'],5500,8000,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),

(s64,'Mist Glass Suite',2,1,ARRAY['King Bed','Glass Panels','Waterfall View','En-suite'],10500,15000,
 ARRAY['https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=800&q=80']),
(s64,'Cloud Room',2,2,ARRAY['Double Bed','Forest View','Shared Bathroom','Hammock'],7000,10000,
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80']),

(s65,'Machan Suite',2,1,ARRAY['King Bed','Sal Tree View','River View','En-suite'],8500,12500,
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80']),
(s65,'Forest Watch Cabin',2,3,ARRAY['Double Bed','Wildlife View','Shared Bathroom'],5500,8000,
 ARRAY['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80']),

(s66,'Sky Bridge Suite',4,2,ARRAY['2 Bedrooms','Sky Bridge Access','Campfire Deck','En-suite'],9000,13000,
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80']),
(s66,'Lower Treehouse',2,3,ARRAY['Double Bed','Forest View','En-suite','Hammock'],6000,9000,
 ARRAY['https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80']),

(s67,'Moss Roof Suite',2,1,ARRAY['King Bed','Bamboo Walls','Canopy View','En-suite'],7500,11000,
 ARRAY['https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=800&q=80']),
(s67,'Rainforest Den',2,3,ARRAY['Double Bed','Forest View','Shared Bathroom','Hammock'],5000,7500,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),

(s68,'Coffee Canopy Suite',2,2,ARRAY['King Bed','Coffee Estate View','Open Deck','En-suite'],8000,12000,
 ARRAY['https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=800&q=80']),
(s68,'Tribal Art Room',2,3,ARRAY['Double Bed','Valley View','En-suite','Traditional Decor'],5500,8000,
 ARRAY['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80']),

-- s69–s70
(s69,'Hilltop Non-AC Room',2,4,ARRAY['Double Bed','Tea Estate View','Fan','En-suite'],1900,2800,
 ARRAY['https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=800&q=80']),
(s69,'Breezy Dorm',4,2,ARRAY['Bunk Beds','Mountain View','Shared Bathroom','Fan'],1100,1700,
 ARRAY['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80']),

(s70,'Fireplace Heritage Room',2,4,ARRAY['Double Bed','Fireplace','Mountain View','En-suite'],2100,3200,
 ARRAY['https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80']),
(s70,'Cool Mountain Dorm',4,2,ARRAY['Bunk Beds','Valley View','Shared Bathroom'],1200,1900,
 ARRAY['https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=800&q=80']);


-- ============================================================
-- RESORT STORIES & REELS (stay_reels for s01–s20 + some new)
-- One reel per stay for stories; multi-reel stays show multiple story bubbles
-- Thumbnails = Unsplash portrait images; URLs = real YouTube travel shorts
-- ============================================================
INSERT INTO public.stay_reels
  (stay_id, title, thumbnail, url, platform, sort_order)
VALUES

-- s01 – The Lovers' Nest
(s01,'Coorg Morning Mist','https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=400&q=80&ar=9:16','https://www.youtube.com/shorts/demo-coorg-01','youtube',1),
(s01,'Coffee Trail Walk','https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-coorg-02/','instagram',2),

-- s02 – Misty Pines Cottage
(s02,'Tea Garden at Dusk','https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-munnar-01','youtube',1),
(s02,'Valley Sunrise','https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-munnar-02/','instagram',2),

-- s03 – Rosewood Hideaway
(s03,'Ooty Rose Gardens','https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-ooty-01','youtube',1),
(s03,'Evening Bonfire','https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-ooty-02/','instagram',2),

-- s04 – Happy Trails Family Resort
(s04,'Kids'' Adventure Zone','https://images.unsplash.com/photo-1510525009256-d4926e8c820f?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-wayanad-01','youtube',1),
(s04,'Jungle Trek','https://images.unsplash.com/photo-1533104816931-20fa691ff6ca?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-wayanad-02/','instagram',2),

-- s05 – The Farmstead
(s05,'Farm Life Morning','https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-lonavala-01','youtube',1),
(s05,'Pool Side Vibes','https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-lonavala-02/','instagram',2),

-- s06 – Riverside Family Bungalow
(s06,'Cauvery Sunrise','https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-river-01','youtube',1),
(s06,'BBQ Night','https://images.unsplash.com/photo-1509233725247-49e657c54213?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-river-02/','instagram',2),

-- s07 – Aurum Grand Resort & Spa
(s07,'Infinity Pool at Sunset','https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-udaipur-01','youtube',1),
(s07,'Lake Pichola View','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-udaipur-02/','instagram',2),
(s07,'Ayurvedic Spa Tour','https://images.unsplash.com/photo-1551882547-ff40c63fe2e2?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-udaipur-03','youtube',3),

-- s08 – Serenity Blue Beach Resort
(s08,'Overwater Magic','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-andaman-01','youtube',1),
(s08,'Snorkeling at Sunrise','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-andaman-02/','instagram',2),

-- s09 – The Highland Palace
(s09,'Shimla Ridge Walk','https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-shimla-01','youtube',1),
(s09,'Heritage Library','https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-shimla-02/','instagram',2),

-- s10 – Emerald Canopy Luxury Lodge
(s10,'Elephant Sighting','https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-corbett-01','youtube',1),
(s10,'Safari at Dawn','https://images.unsplash.com/photo-1544465544-1b71aee9dfa3?auto=format&fit=crop&w=800&q=80','https://www.instagram.com/reel/demo-corbett-02/','instagram',2),
(s10,'Jungle Sunset','https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-corbett-03','youtube',3),

-- s11 – Backpackers' Base Camp
(s11,'Old Manali Views','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-manali-01','youtube',1),
(s11,'Rooftop Bonfire','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-manali-02/','instagram',2),

-- s12 – The Yellow Door Hostel
(s12,'Rishikesh River Life','https://images.unsplash.com/photo-1483653364400-eedcfb9f1f88?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-rishikesh-01','youtube',1),
(s12,'Morning Yoga','https://images.unsplash.com/photo-1500259571355-332da5cb07aa?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-rishikesh-02/','instagram',2),

-- s14 – Azure Infinity Villa
(s14,'Goa Infinity Pool','https://images.unsplash.com/photo-1560813889-a6c4acfb7e76?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-goa-01','youtube',1),
(s14,'Sunset on the Veranda','https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-goa-02/','instagram',2),

-- s17 – Cobalt Cove Villa
(s17,'Clifftop Arabian Sea','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-varkala-01','youtube',1),
(s17,'Pool at Golden Hour','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-varkala-02/','instagram',2),

-- s18 – The Canopy Nest
(s18,'Athirapally Waterfall','https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-athira-01','youtube',1),
(s18,'Treehouse Morning','https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-athira-02/','instagram',2),

-- s19 – Whispering Pines Treehouse
(s19,'Kodaikanal Pine Forest','https://images.unsplash.com/photo-1476514555960-1153cced88c4?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-kodai-01','youtube',1),
(s19,'Treetop Sunrise','https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-kodai-02/','instagram',2),

-- s20 – Jungle Crown Treehouse
(s20,'Wayanad Canopy','https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-wayanad2-01','youtube',1),
(s20,'Elephant Spotting Deck','https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-wayanad2-02/','instagram',2),
(s20,'Night Sky in the Jungle','https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-wayanad2-03','youtube',3),

-- new stays reels
(s21,'Moonlit Coorg','https://images.unsplash.com/photo-1596178060892-41a89668cc12?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-coorg2-01','youtube',1),
(s26,'Milky Way Spiti','https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-spiti-01','youtube',1),
(s37,'Desert Fort Nights','https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-jaisalmer-01','youtube',1),
(s40,'Blue City Haveli','https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-jodhpur-01/','instagram',1),
(s44,'Lakshadweep Lagoon','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-lakshadweep-01','youtube',1),
(s53,'South Goa Palm Villa','https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-sgoa-01/','instagram',1),
(s57,'Kerala Backwaters','https://images.unsplash.com/photo-1586375300773-8384e3e4916f?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-alleppey-01','youtube',1),
(s62,'Eagle''s Nest Coorg','https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?auto=format&fit=crop&w=400&q=80','https://www.instagram.com/reel/demo-coorg3-01/','instagram',1),
(s64,'Meghalaya Root Bridges','https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=400&q=80','https://www.youtube.com/shorts/demo-meghalaya-01','youtube',1);

END $$;
