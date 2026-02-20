package com.crop.controller;

import com.crop.dto.LoginRequest;
import com.crop.dto.LoginResponse;
import com.crop.entity.enums.Role;
import com.crop.service.UserService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;

/**
 * Thymeleaf pages: login, register, dashboard.
 */
@Controller
@RequiredArgsConstructor
public class WebController {

    private final UserService userService;

    @GetMapping("/")
    public String home() {
        return "home";
    }

    @GetMapping("/login")
    public String loginPage(Model model) {
        model.addAttribute("loginRequest", new LoginRequest());
        return "login";
    }

    @PostMapping("/do-login")
    public String doLogin(
            @ModelAttribute LoginRequest loginRequest,
            HttpServletResponse response,
            RedirectAttributes redirectAttributes) {
        try {
            LoginResponse auth = userService.login(loginRequest);
            Cookie cookie = new Cookie("token", auth.getToken());
            cookie.setPath("/");
            cookie.setHttpOnly(true);
            cookie.setMaxAge(24 * 60 * 60); // 24 hours
            response.addCookie(cookie);
            return "redirect:/dashboard";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Invalid email or password");
            return "redirect:/login";
        }
    }

    @GetMapping("/register")
    public String registerPage(Model model) {
        model.addAttribute("registerRequest", new com.crop.dto.RegisterRequest());
        model.addAttribute("roles", Role.values());
        return "register";
    }

    @PostMapping("/do-register")
    public String doRegister(
            @ModelAttribute com.crop.dto.RegisterRequest registerRequest,
            HttpServletResponse response,
            RedirectAttributes redirectAttributes) {
        try {
            LoginResponse auth = userService.register(registerRequest);
            Cookie cookie = new Cookie("token", auth.getToken());
            cookie.setPath("/");
            cookie.setHttpOnly(true);
            cookie.setMaxAge(24 * 60 * 60);
            response.addCookie(cookie);
            return "redirect:/dashboard";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/register";
        }
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        if (userDetails == null) {
            return "redirect:/login";
        }
        var user = userService.findByEmail(userDetails.getUsername());
        model.addAttribute("userName", user.getName());
        model.addAttribute("userRole", user.getRole().name());
        model.addAttribute("userId", user.getId());
        return "dashboard";
    }

    @GetMapping("/logout")
    public String logout(HttpServletResponse response) {
        Cookie cookie = new Cookie("token", "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        response.addCookie(cookie);
        return "redirect:/login";
    }
}
