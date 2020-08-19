package com.example.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApiController {

	@Value("${myvariables.mykey}")
	private String mykey;
	
	@Value("${myvariables.myenv}")
	private String myenv;
	@GetMapping("/")
	public String Names()
	{
		return "My Key:  " + mykey +  " My Env: " + myenv;
	}
}
