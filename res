1795637777068740979
	.remove = jadard_dsi_remove,
	.driver = {
		.name = "jadard-jd9365da",
		.of_match_table = jadard_of_match,
	},
};
module_mipi_dsi_driver(jadard_driver);

MODULE_AUTHOR("Jagan Teki <jagan@edgeble.ai>");
MODULE_AUTHOR("Stephen Chen <stephen@radxa.com>");
MODULE_DESCRIPTION("Jadard JD9365DA-H3 WXGA DSI panel");
MODULE_LICENSE("GPL");
=== antal rader:
3360 panel-jadard-jd9365da-h3.c
