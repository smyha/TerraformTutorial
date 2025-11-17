# Application Load Balancer (ALB) Configuration

This Terraform configuration demonstrates how to create and configure an **Application Load Balancer (ALB)** that can sit in front of Auto Scaling Groups to distribute traffic across EC2 instances.

## Overview

An Application Load Balancer (ALB) is a Layer 7 (Application Layer) load balancer that distributes incoming application traffic across multiple targets, such as EC2 instances. The ALB automatically scales the number of load balancer servers and handles failover, providing high availability out of the box.

## Architecture

```
Internet Users
      |
      v (HTTP Port 80)
+----------+
|    ALB   |
| (scaled  | <-- Multiple servers in different AZs
| by AWS)  |
+----------+
      |
      | (Port 8080)
      v
+-----------+    +-----------+
| Instance1 |    | Instance2 |
|  (Port    |    |  (Port    |
|  8080)    |    |  8080)    |
+-----------+    +-----------+
  (AZ1)           (AZ2)
```

## Key Components

### 1. Application Load Balancer (`aws_lb`)

The ALB itself consists of multiple servers running in separate subnets (separate datacenters). AWS automatically:
- Scales the number of load balancer servers up and down based on traffic
- Handles failover if one load balancer server goes down
- Distributes requests across multiple targets

**Features:**
- Operates at Layer 7 (Application Layer)
- Can route based on hostnames, paths, HTTP methods
- Supports WebSockets and HTTP/2
- Cross-zone load balancing by default

### 2. Listener (`aws_lb_listener`)

A listener checks for incoming traffic on a specified port and protocol. Each ALB must have at least one listener.

**Configuration:**
- **Port:** 80 (HTTP) or 443 (HTTPS)
- **Protocol:** HTTP, HTTPS
- **Default Action:** What to do with requests that don't match any rules

In this example:
- Listens on port 80
- Returns 404 for unmatched requests
- Can be extended with rules to forward traffic to target groups

### 3. Target Group (`aws_lb_target_group`)

A target group specifies where to route traffic and how to determine if instances are healthy.

**Health Checks:**
- Periodically sends HTTP requests to instances
- Considers instance "healthy" only if it returns a matching HTTP status code
- Marks unhealthy instances and stops sending traffic to them
- Automatically removes unhealthy instances from rotation

**Configuration in this example:**
```
Health Check Every: 15 seconds
Timeout:            3 seconds
Healthy After:      2 consecutive successful checks
Unhealthy After:    2 consecutive failed checks
Expected Response:  HTTP 200
```

### 4. Listener Rules (`aws_lb_listener_rule`)

Listener rules determine which target group receives traffic based on conditions.

**Conditions can be:**
- Path pattern (e.g., `/api/*`, `/images/*`)
- Hostname (e.g., `api.example.com`)
- HTTP method (GET, POST, etc.)
- HTTP headers
- IP address (source IP)
- Query parameters

In this example:
- Rule matches ALL paths (`*`)
- Forwards all traffic to the ASG target group

### 5. Security Groups

**ALB Security Group:**
- Allows inbound HTTP (80) and HTTPS (443) from anywhere
- Allows all outbound traffic (for health checks)

**Instance Security Group:**
- Allows inbound traffic ONLY from the ALB on the server port
- Prevents direct public access to instances

## File Structure

```
load-balancer/
├── main.tf              # ALB, Listener, Target Group, Security Groups
├── variables.tf         # Variable definitions with validation
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values
└── README.md            # This file
```

## Components Explained

### Security Model

```
Internet
   |
   | (80)
   v
[ALB SG] - Allows 80, 443 inbound
   |
   | (8080)
   v
[Instance SG] - Allows 8080 ONLY from ALB
   |
   v
EC2 Instances
```

### Health Check Flow

```
1. ALB sends HTTP GET /
2. Instance receives request on port 8080
3. Instance responds with HTTP 200
4. ALB marks instance as HEALTHY
5. ALB continues sending traffic to instance

OR

1. ALB sends HTTP GET /
2. Instance doesn't respond (timeout)
3. After 2 failed checks: Mark as UNHEALTHY
4. ALB stops sending traffic to instance
5. ASG can replace unhealthy instances
```

### Traffic Routing

```
User Request (Port 80)
        |
        v
    ALB Listener
        |
    (Check Rules)
        |
        v
Listener Rule (Path = *)
        |
        v
Target Group (Port 8080)
        |
        +---> Instance 1 (HEALTHY)
        |
        +---> Instance 2 (HEALTHY)
        |
        X---> Instance 3 (UNHEALTHY - no traffic)
```

## Deployment

### Prerequisites
- AWS credentials configured
- Terraform 1.0+

### Deploy

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

### Output

After deployment, you'll see the ALB DNS name:

```bash
alb_dns_name = "terraform-asg-example-123.us-east-2.elb.amazonaws.com"
```

## Usage

### Access the ALB

```bash
# Get the ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test with curl
curl http://$ALB_DNS

# In browser: http://terraform-asg-example-123.us-east-2.elb.amazonaws.com
```

### Add Listener Rules (Example)

```hcl
# Route /api/* to a different target group
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1  # Higher priority than default

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
```

### Use with Auto Scaling Group

To use this ALB with an ASG, add this to your ASG configuration:

```hcl
resource "aws_autoscaling_group" "example" {
  # ... other ASG configuration ...

  # Register with the target group
  target_group_arns = [aws_lb_target_group.asg.arn]

  # Use ELB health checks (more robust than EC2 checks)
  health_check_type = "ELB"
}
```

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-2 | AWS region |
| `alb_name` | string | terraform-asg-example | ALB name (max 32 chars) |
| `alb_security_group_name` | string | terraform-example-alb | ALB SG name |
| `instance_security_group_name` | string | terraform-example-instance | Instance SG name |
| `target_group_name` | string | terraform-asg-example | Target group name (max 32 chars) |
| `server_port` | number | 8080 | Instance port (1024-65535) |

## Outputs

- `alb_dns_name` - DNS name to access the ALB
- `alb_arn` - ARN of the ALB
- `target_group_arn` - ARN of the target group
- `alb_security_group_id` - ALB security group ID
- `instance_security_group_id` - Instance security group ID

## Advanced Features

### Multi-Region Load Balancing

```hcl
# Create ALB in different region
provider "aws" {
  alias  = "eu"
  region = "eu-west-1"
}

resource "aws_lb" "eu" {
  provider   = aws.eu
  # ... configuration ...
}
```

### HTTPS Support

```hcl
# Add HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:..."

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
```

### Fixed Response Action

```hcl
# Return fixed response instead of forwarding
action {
  type = "fixed-response"

  fixed_response {
    content_type = "text/plain"
    message_body = "Service Unavailable"
    status_code  = "503"
  }
}
```

### Redirect Action

```hcl
# Redirect HTTP to HTTPS
action {
  type = "redirect"

  redirect {
    port        = "443"
    protocol    = "HTTPS"
    status_code = "HTTP_301"
  }
}
```

## Best Practices

1. ✓ **Use ALBs for web applications** (Layer 7 routing)
2. ✓ **Enable cross-zone load balancing** (default)
3. ✓ **Configure proper health checks** (not too aggressive)
4. ✓ **Use separate security groups** (ALB ≠ Instances)
5. ✓ **Monitor target health** (CloudWatch metrics)
6. ✓ **Use listener rules** for routing logic
7. ✓ **Enable access logs** for troubleshooting
8. ✓ **Set deletion protection** in production

## Cleanup

```bash
terraform destroy
```

## Cost

- **ALB:** ~$0.0225/hour (~$16/month)
- **Data Processing:** ~$0.006 per LCU (1M new connections, 1B processed bytes, or 1000 rule evaluations)
- **Eligible for AWS Free Tier** (750 hours/month for 12 months)

## Further Reading

- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html)
- [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
- [Listener Rules](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html)
- [Health Checks](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-health-checks.html)
