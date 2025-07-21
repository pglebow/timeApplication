package com.glebow.timeApplication.controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.ZonedDateTime;

@RestController
public class TimeController {

    @GetMapping("/time")
    public String getTime() {
        return ZonedDateTime.now().toString();
    }
}
