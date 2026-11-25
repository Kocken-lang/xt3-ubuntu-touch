1795637813277605754
panel_jadard_jd9365da_h3.license=GPL
using_gplonly_symbols
---
     1			.compatible = "waveshare,10.1-dsi-touch-b",
     2			.data = &waveshare_10_1_inch_b_desc
     3		},
     4		{ /* sentinel */ }
     5	};
     6	MODULE_DEVICE_TABLE(of, jadard_of_match);
     7	
     8	static struct mipi_dsi_driver jadard_driver = {
     9		.probe = jadard_dsi_probe,
    10		.remove = jadard_dsi_remove,
    11		.driver = {
    12			.name = "jadard-jd9365da",
    13			.of_match_table = jadard_of_match,
    14		},
    15	};
    16	module_mipi_dsi_driver(jadard_driver);
    17	
    18	MODULE_AUTHOR("Jagan Teki <jagan@edgeble.ai>");
    19	MODULE_AUTHOR("Stephen Chen <stephen@radxa.com>");
    20	MODULE_DESCRIPTION("Jadard JD9365DA-H3 WXGA DSI panel");
    21	MODULE_LICENSE("GPL");
