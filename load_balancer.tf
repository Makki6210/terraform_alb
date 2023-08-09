locals {
  lb_tg = [
    {
      name = "tf-lb-tg-ap-northeast-1a"
    },
    {
      name = "tf-lb-tg-ap-northeast-1c"
    }
  ]
  lb_tg_attach = [
    {
      tg_arn = "${aws_lb_target_group.my_lb_target_group["tf-lb-tg-ap-northeast-1a"].arn}"
      tg_id  = "${aws_instance.web_server["ap-northeast-1a"].id}"
      name   = "attach_1"
    },
    {
      tg_arn = "${aws_lb_target_group.my_lb_target_group["tf-lb-tg-ap-northeast-1c"].arn}"
      tg_id  = "${aws_instance.web_server["ap-northeast-1c"].id}"
      name   = "attach_2"
    }
  ]
}

# ---------------------------
# Load Balancer
# ---------------------------
resource "aws_lb" "my_lb" {
#  for_each           = aws_subnet.my_pub_subnet
  name               = "tf-application-loadbalancer"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb.id}"]
  subnets            = ["${aws_subnet.my_pub_subnet["ap-northeast-1a"].id}", "${aws_subnet.my_pub_subnet["ap-northeast-1c"].id}"]
  internal           = false
}

resource "aws_lb_target_group" "my_lb_target_group" {
  for_each = { for i in local.lb_tg : i.name => i }
  name     = each.value.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_target_group_attachment" "my_lb_tg" {
  for_each         = { for i in local.lb_tg_attach : i.name => i }
  target_group_arn = each.value.tg_arn
  target_id        = each.value.tg_id
  port             = 80
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my_lb_target_group["tf-lb-tg-ap-northeast-1a"].arn}"
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.my_lb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my_lb_target_group["tf-lb-tg-ap-northeast-1c"].arn}"
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}