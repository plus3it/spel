"""Deletes all s3 objects."""
# modified from https://gist.github.com/seventhskye/0cc7b2804252975d36dca047ab7729e9s

import boto3

client = boto3.client('s3')


def delete_all_objects(bucket, prefix='', verbose=False):
    """Delete all s3 objects and their versions."""
    IsTruncated = True
    MaxKeys = 1000
    KeyMarker = None
    try:
        while IsTruncated:
            if not KeyMarker:
                    version_list = client.list_object_versions(
                            Bucket=bucket,
                            MaxKeys=MaxKeys,
                            Prefix=prefix)
            else:
                    version_list = client.list_object_versions(
                            Bucket=bucket,
                            MaxKeys=MaxKeys,
                            Prefix=prefix,
                            KeyMarker=KeyMarker)

            try:
                objects = []
                versions = version_list['Versions']
                for v in versions:
                    objects.append(
                          {
                            'VersionId': v['VersionId'],
                            'Key': v['Key']
                          }
                      )
                    response = client.delete_objects(
                      Bucket=bucket, Delete={'Objects': objects})
                    if verbose:
                        print(response)
            except KeyError:
                pass

                try:
                    objects = []
                    delete_markers = version_list['DeleteMarkers']
                    for d in delete_markers:
                        objects.append(
                              {
                                'VersionId': d['VersionId'],
                                'Key': d['Key']
                              }
                          )
                    response = client.delete_objects(
                      Bucket=bucket, Delete={'Objects': objects})
                    if verbose:
                        print(response)
                except KeyError:
                    pass
                    IsTruncated = version_list['IsTruncated']
                    KeyMarker = version_list['NextKeyMarker']
    except KeyError:
        if verbose:
            print("{} is empty".format(bucket))
