# Deployment Checklist

## Pre-Deploy
- [ ] Run test suite
- [ ] Check migrations
- [ ] Review env variables
- [ ] Verify secrets rotation

## Deploy Steps
- [ ] Tag release
- [ ] Build container image
- [ ] Push to registry
- [ ] Update manifests
- [ ] Apply to staging

## Post-Deploy
- [ ] Smoke tests
- [ ] Check error rates
- [ ] Monitor latency
- [ ] Verify rollback plan

## Rollback
- [ ] Revert manifests
- [ ] Restore database
- [ ] Clear cache
- [ ] Notify team

## Sign-off
- [ ] QA approved
- [ ] Security reviewed
- [ ] PM notified
